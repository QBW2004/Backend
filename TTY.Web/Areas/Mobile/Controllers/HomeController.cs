using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Mobile.Controllers
{
    [MemberAuthorize]
    public class HomeController : BaseController
    {
        // GET: Mobile/Home
        public ActionResult Index()
        {
            return View();
        }

        // GET: Mobile/Home/Details/5
        public ActionResult Details(int id)
        {
            return View();
        }

        // GET: Mobile/Home/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: Mobile/Home/Create
        [HttpPost]
        public ActionResult Create(FormCollection collection)
        {
            try
            {
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: Mobile/Home/Edit/5
        public ActionResult Edit(int id)
        {
            return View();
        }

        // POST: Mobile/Home/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        {
            try
            {
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }

        // GET: Mobile/Home/Delete/5
        public ActionResult Delete(int id)
        {
            return View();
        }

        // POST: Mobile/Home/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}
