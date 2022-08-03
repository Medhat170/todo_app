import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udemy_flutter/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpper = true,
  double radius = 3.0,
  required String text,
  required Function() function,
}) => Container(
  width: width,
  child: MaterialButton(
    onPressed: function,
    child: Text(
      isUpper ? text.toUpperCase() : text,
      style: const TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),
    ),
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadiusDirectional.circular(radius),
    color: background,
  ),
);

Widget defaultTextButton({
  required Function() function,
  required String text
}) => TextButton(
  onPressed: function,
  child: Text(text.toUpperCase(),),
);

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  Function(String s)? onSubmit,
  Function(String s)? onChanged,
  Function()? onTap,
  Function? suffixPressed,
  bool isPassword = false,
  required String? Function(String? value) validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
})
 =>TextFormField(
  controller: controller,
  keyboardType: type,
  obscureText: isPassword,
  onFieldSubmitted: onSubmit,
  onChanged: onChanged,
  onTap: onTap,
  validator: validate,
   decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(
        prefix,
      ),
      suffixIcon: suffix != null ? IconButton(
        onPressed: ()
        {
          suffixPressed!();
        },
        icon: Icon(
        suffix,
    ),
      ) : null,
  ),
);

Widget buildTasksItem(Map model,context) => Dismissible(
  key: Key(model['id'].toString()),
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children:
      [
        CircleAvatar(
          radius: 40.0,
          child: Text(
            '${model['time']}',
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
            [
              Text(
                '${model['title']}',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${model['date']}',
                style: const TextStyle(
                    color: Colors.grey
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateData(
                status: 'done',
                id: model['id']
            );
          },
          icon: const Icon(
            Icons.check_box,
            color: Colors.green,
          ),
        ),
        IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateData(
                status: 'archive',
                id: model['id']
            );
          },
          icon: const Icon(
            Icons.archive_outlined,
            color: Colors.black45,
          ),
        ),
      ],
    ),
  ),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(id: model['id']);
  },
);

Widget tasksBuilder({
  required List<Map> tasks,
}) => ConditionalBuilder(
  condition: tasks.isNotEmpty,
  builder: (context) => ListView.separated(
    itemBuilder: (context, index) => buildTasksItem(tasks[index],context),
    separatorBuilder: (context, index) => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    ),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);

Widget myDivider () => Padding(
  padding: const EdgeInsetsDirectional.only(
    start: 20.0,
  ),
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[300],
  ),
);

Widget buildArticlesItem(article, context) => Padding(
  padding: const EdgeInsets.all(20.0),
  child: Row(
    children: [
      Container(
          width: 120.0,
          height: 120.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage('${article['urlToImage']}'),
              fit: BoxFit.cover,
            ),

          )
      ),
      const SizedBox(
        width: 15.0,
      ),
      Expanded(
        child: Container(
          height: 120.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${article['title']}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Text(
                '${article['publishedAt']}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);

Widget articleBuilder(list, context) => ConditionalBuilder(
  condition: list.length >0,
  builder: (context) => ListView.separated(
    physics: const BouncingScrollPhysics(),
    itemBuilder: (context, index) => buildArticlesItem(list[index], context),
    separatorBuilder: (context, index) => myDivider(),
    itemCount: list.length,
  ),
  fallback: (context) => const Center(child: CircularProgressIndicator()),
);

void navigateTo(context, widget) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) =>  widget,
  ),
);

void navigateAndFinish(
    context,
    widget,
    ) =>
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => widget,
            ),
             (route) => false
        );

