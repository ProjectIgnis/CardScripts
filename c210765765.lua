Senya=Senya or {}
local cm=Senya
--7CG universal scripts
--test parts
aux.BeginPuzzle=aux.TRUE
cm.delay=0x14000
cm.fix=0x40400
cm.m=210765765

function cm.DescriptionInNanahira(id)
	id=id or 0
	return 210765765*16+id
end
cm.loaded_metatable_list=cm.loaded_metatable_list or {}
function cm.LoadMetatable(code)
	local m1=_G["c"..code]
	if m1 then return m1 end
	local m2=cm.loaded_metatable_list[code]
	if m2 then return m2 end
	_G["c"..code]={}
	if pcall(function() dofile("expansions/script/c"..code..".lua") end) or pcall(function() dofile("script/c"..code..".lua") end) then
		local mt=_G["c"..code]
		_G["c"..code]=nil
		if mt then
			cm.loaded_metatable_list[code]=mt
			return mt
		end
	else
		_G["c"..code]=nil
	end
end
function cm.check_set(c,setcode,v,f,...)	
	local codet=nil
	if type(c)=="number" then
		codet={c}
	elseif type(c)=="table" then
		codet=c
	elseif type(c)=="userdata" then
		local f=f or Card.GetCode
		codet={f(c)}
	end
	local ncodet={...}
	for i,code in pairs(codet) do
		for i,ncode in pairs(ncodet) do
			if code==ncode then return true end
		end
		local mt=cm.LoadMetatable(code)
		if mt and mt["Senya_name_with_"..setcode] and (not v or mt["Senya_name_with_"..setcode]==v) then return true end
	end
	return false
end
function cm.check_set_elem(c)
	return cm.check_set(c,"elem")
end
function cm.check_fusion_set_elem(c)
	if c:IsHasEffect(6205579) then return false end
	return cm.check_set(c,"elem",nil,Card.GetFusionCode)
end
function cm.check_set_rose(c)
	return cm.check_set(c,"rose")
end
function cm.check_set_sawawa(c)
	return cm.check_set(c,"sawawa")
end
function cm.check_set_prism(c)
	return cm.check_set(c,"prism")
end
function cm.check_fusion_set_prism(c)
	if c:IsHasEffect(6205579) then return false end
	return cm.check_set(c,"prism",nil,Card.GetFusionCode)
end
function cm.check_set_prim(c)
	return cm.check_set(c,"prim")
end
function cm.check_set_sayuri(c)
	return cm.check_set(c,"sayuri") or c:IsHasEffect(210765900)
end
function cm.check_link_set_sayuri(c)
	return cm.check_set(c,"sayuri",nil,Card.GetLinkCode) or c:IsHasEffect(210765900)
end
function cm.check_set_remix(c)
	return cm.check_set(c,"remix")
end
function cm.check_set_3L(c)
	if c:IsHasEffect(210765800) then return true end
	local codet={c:GetCode()}
	for j,code in pairs(codet) do
		local mt=cm.LoadMetatable(code)
		if mt then
			for str,v in pairs(mt) do   
				if type(str)=="string" and str:find("_3L") and v then return true end
			end
		end
	end
	return false
end
function cm.check_link_set_3L(c)
	if c:IsHasEffect(210765800) then return true end
	local codet={c:GetLinkCode()}
	for j,code in pairs(codet) do
		local mt=cm.LoadMetatable(code)
		if mt then
			for str,v in pairs(mt) do   
				if type(str)=="string" and str:find("_3L") and v then return true end
			end
		end
	end
	return false
end
function cm.check_fusion_set_3L(c)
	if c:IsHasEffect(6205579) then return false end
	if c:IsHasEffect(210765800) then return true end
	local codet={c:GetFusionCode()}
	for j,code in pairs(codet) do
		local mt=cm.LoadMetatable(code)
		if mt then
			for str,v in pairs(mt) do   
				if type(str)=="string" and str:find("_3L") and v then return true end
			end
		end
	end
	return false
end
function cm.RegisterSingleEffect(c,setcd)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(setcd)
	c:RegisterEffect(e1)
	return e1
end
function cm.GetValueType(v)
	local t=type(v)
	if t=="userdata" then
		local mt=getmetatable(v)
		if mt==Group then return "Group"
		elseif mt==Effect then return "Effect"
		else return "Card" end
	else return t end
end
function cm.CheckGroupRecursive(c,sg,g,f,min,max,ext_params)
	sg:AddCard(c)
	local res=(#sg>=min and #sg<=max and f(sg,table.unpack(ext_params)))
		or (#sg<max and g:IsExists(cm.CheckGroupRecursive,1,sg,sg,g,f,min,max,ext_params))
	sg:RemoveCard(c)
	return res
end
function cm.CheckGroup(g,f,cg,min,max,...)
	local min=min or 1
	local max=max or #g
	if min>max then return false end
	local ext_params={...}
	local sg=Group.CreateGroup()
	if cg then sg:Merge(cg) end
	if #sg>=min and #sg<=max and f(sg,...) then return true end
	return g:IsExists(cm.CheckGroupRecursive,1,sg,sg,g,f,min,max,ext_params)
end
function cm.SelectGroupNew(tp,desc,cancelable,g,f,cg,min,max,...)
	local min=min or 1
	local max=max or #g
	local ext_params={...}
	local sg=Group.CreateGroup()
	local cg=cg or Group.CreateGroup()
	sg:Merge(cg)
	local ag=g:Filter(cm.CheckGroupRecursive,sg,sg,g,f,min,max,ext_params)	
	while #sg<max and #ag>0 do
		local seg=sg:Clone()
		seg:Sub(cg)
		local finish=(#sg>=min and #sg<=max and f(sg,...))
		local cancel=cancelable and not finish
		local dmin=#sg
		local dmax=math.min(max,#g)
		local tc=nil
		repeat
			Duel.Hint(HINT_SELECTMSG,tp,desc)
			tc=ag:SelectUnselect(sg,tp,finish,cancel,dmin,dmax)
		until not tc or ag:IsContains(tc) or seg:IsContains(tc)
		if not tc then
			if not finish then return end
			break
		end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
		else
			sg:AddCard(tc)
		end
		ag=g:Filter(cm.CheckGroupRecursive,sg,sg,g,f,min,max,ext_params)
	end
	return sg
end
function cm.SelectGroup(tp,desc,g,f,cg,min,max,...)
	return cm.SelectGroupNew(tp,desc,false,g,f,cg,min,max,...)
end
function cm.SelectGroupWithCancel(tp,desc,g,f,cg,min,max,...)
	return cm.SelectGroupNew(tp,desc,true,g,f,cg,min,max,...)
end

--updated overlay
function cm.OverlayCard(c,tc,xm,nchk)
	if not nchk and (not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not c:IsType(TYPE_XYZ) or tc:IsType(TYPE_TOKEN)) then return end
	if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
		tc:CancelToGrave()
	end
	if tc:GetOverlayCount()>0 then
		local og=tc:GetOverlayGroup()
		if xm then
			Duel.Overlay(c,og)
		else
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
	Duel.Overlay(c,tc)
end
function cm.OverlayFilter(c,nchk)
	return nchk or not c:IsType(TYPE_TOKEN)
end
function cm.OverlayGroup(c,g,xm,nchk)
	if not nchk and (not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or #g<=0 or not c:IsType(TYPE_XYZ)) then return end
	local tg=g:Filter(cm.OverlayFilter,nil,nchk)
	if #tg==0 then return end
	local og=Group.CreateGroup()
	for tc in aux.Next(tg) do
		if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
			tc:CancelToGrave()
		end
		og:Merge(tc:GetOverlayGroup())
	end
	if #og>0 then
		if xm then
			Duel.Overlay(c,og)
		else
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
	Duel.Overlay(c,tg)
end
function cm.CheckFieldFilter(g,tp,c,f,...)
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and (not f or f(g,...))
	else
		return Duel.GetMZoneCount(tp,g,tp)>0 and (not f or f(g,...))
	end
end
function cm.MustMaterialCheck(v,tp,code)
	return aux.MustMaterialCheck(v,tp,code)
end
--xyz summon of prim
function cm.AddXyzProcedureRank(c,rk,f,minct,maxct,xm,exop,...)
	local ext_params={...}
	return cm.AddXyzProcedureCustom(c,cm.XyzProcedureRankFilter(rk,f,ext_params),cm.XyzProcedureRankCheck,minct,maxct,xm,exop)
end
function cm.XyzProcedureRankFilter(rk,f,ext_params)
return function(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and (not rk or c:GetRank()==rk) and (not f or f(c,xyzc,table.unpack(ext_params)))
end
end
function cm.XyzProcedureRankCheck(g,xyzc)
	return g:GetClassCount(Card.GetRank)==1
end
function cm.XyzProcedureCustomCheck(g,xyzc,tp,gf)
	if g:IsExists(aux.TuneMagicianCheckX,nil,g,EFFECT_TUNE_MAGICIAN_X) then return false end
	return not gf or gf(g,xyzc,tp)
end
function cm.AddXyzProcedureCustom(c,func,gf,minc,maxc,xm,exop,...)
	local ext_params={...}
	c:EnableReviveLimit()
	local maxc=maxc or minc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.XyzProcedureCustomCondition(func,gf,minc,maxc,ext_params))
	e1:SetTarget(cm.XyzProcedureCustomTarget(func,gf,minc,maxc,ext_params))
	e1:SetOperation(cm.XyzProcedureCustomOperation(xm,exop))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function cm.XyzProcedureCustomFilter(c,xyzcard,func,ext_params)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeXyzMaterial(xyzcard) and (not func or func(c,xyzcard,table.unpack(ext_params)))
end
function cm.XyzProcedureCustomCondition(func,gf,minct,maxct,ext_params)
	return function(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local minc=minct or 2
		local maxc=maxct or minct or 63
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.XyzProcedureCustomFilter,nil,c,func,ext_params)
		else
			mg=Duel.GetMatchingGroup(cm.XyzProcedureCustomFilter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
		end
		local sg=Group.CreateGroup()
		local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_XMATERIAL)}
		for _,te in ipairs(ce) do
			local tc=te:GetHandler()
			if not mg:IsContains(tc) then return false end
			sg:AddCard(tc)
		end
		return maxc>=minc and cm.CheckGroup(mg,cm.CheckFieldFilter,sg,minc,maxc,tp,c,cm.XyzProcedureCustomCheck,c,tp,gf)
	end
end
function cm.XyzProcedureCustomTarget(func,gf,minct,maxct,ext_params)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
		local g=nil
		if og and not min then
			g=og
		else
			local mg=nil
			if og then
				mg=og:Filter(cm.XyzProcedureCustomFilter,nil,c,func,ext_params)
			else
				mg=Duel.GetMatchingGroup(cm.XyzProcedureCustomFilter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
			end
			local minc=minct or 2
			local maxc=maxct or minct or 63
			if min then
				minc=math.max(minc,min)
				maxc=math.min(maxc,max)
			end
			local sg=Group.CreateGroup()
			local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_XMATERIAL)}
			for _,te in ipairs(ce) do
				local tc=te:GetHandler()
				sg:AddCard(tc)
			end
			g=cm.SelectGroupWithCancel(tp,HINTMSG_XMATERIAL,mg,cm.CheckFieldFilter,sg,minc,maxc,tp,c,cm.XyzProcedureCustomCheck,c,tp,gf)
		end
		if g then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		else return false end
	end
end
function cm.XyzProcedureCustomOperation(xm,exop)
	return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local g=e:GetLabelObject()
		if exop then exop(e,tp,g,c) end
		c:SetMaterial(g)
		cm.OverlayGroup(c,g,xm,true)
		g:DeleteGroup()
	end
end
cm.proc_check_list={
	[Duel.Destroy]=Card.IsDestructable,
	[Duel.SendtoDeck]=Card.IsAbleToDeckOrExtraAsCost,
	[Duel.SendtoExtraP]=Card.IsAbleToDeckOrExtraAsCost,
	[Duel.SendtoHand]=Card.IsAbleToHandAsCost,
	[Duel.SendtoGrave]=Card.IsAbleToGraveAsCost,
	[Duel.Remove]=Card.IsAbleToRemoveAsCost,
	[Duel.Release]=Card.IsReleasable,
}
cm.proc_param_list={
	[Duel.Destroy]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoDeck]={nil,2,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoExtraP]={nil,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoHand]={nil,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoGrave]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.Remove]={POS_FACEUP,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.Release]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
}
--touch fusion proc using fusion material
function cm.AddSelfFusionProcedure(c,loc,opf,fonly,sonly)
	local loc=loc or LOCATION_MZONE
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(cm.DescriptionInNanahira(0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.SelfFusionProcedureCondition(loc,opf))
	e2:SetOperation(cm.SelfFusionProcedureOperation(loc,opf))
	c:RegisterEffect(e2)
	if sonly then
		local e22=Effect.CreateEffect(c)
		e22:SetType(EFFECT_TYPE_SINGLE)
		e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e22:SetCode(EFFECT_SPSUMMON_CONDITION)
		c:RegisterEffect(e22)
	elseif fonly then
		local e22=Effect.CreateEffect(c)
		e22:SetType(EFFECT_TYPE_SINGLE)
		e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e22:SetCode(EFFECT_SPSUMMON_CONDITION)
		e22:SetValue(aux.fuslimit)
		c:RegisterEffect(e22)
	end
	return e2
end
function cm.SelfFusionProcedureFilter(c,fc,opf)
	local f=cm.proc_check_list[opf]
	return c:IsCanBeFusionMaterial(fc) and (not f or f(c))
end
function cm.SelfFusionProcedureCondition(loc,opf)
return function(e,c)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local chkf=tp
	local mg=Duel.GetMatchingGroup(cm.SelfFusionProcedureFilter,tp,loc,0,c,c,opf)
	return c:CheckFusionMaterial(mg,nil,chkf)
end
end
function cm.SelfFusionProcedureOperation(loc,opf)
return function(e,tp,eg,ep,ev,re,r,rp,c)
	local chkf=tp
	local mg=Duel.GetMatchingGroup(cm.SelfFusionProcedureFilter,tp,loc,0,c,c,opf)
	local g=Duel.SelectFusionMaterial(tp,c,mg,nil,chkf)
	c:SetMaterial(g)
	local params=cm.proc_param_list[opf]
	opf(g,table.unpack(params))
end
end
--mokou reborn
function cm.MokouReborn(c,ct,cd,eff,con,exop,excon,comp)
	local comp=comp or false
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(ct,cd)
	e2:SetCondition(cm.MokouRebornCondition(eff,con))
	e2:SetTarget(cm.MokouRebornTarget(comp))
	e2:SetOperation(cm.MokouRebornOperation(exop,excon,comp))
	c:RegisterEffect(e2)
	return e2
end
function cm.MokouRebornCondition(eff,con)
	if eff then
		return function(e,tp,eg,ep,ev,re,r,rp)
			return (e:GetHandler():GetReason() & 0x41)==0x41 and (not con or con(e,tp,eg,ep,ev,re,r,rp))
		end
	else
		return function(e,tp,eg,ep,ev,re,r,rp)
			return e:GetHandler():IsReason(REASON_DESTROY) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
		end
	end
end
function cm.MokouRebornTarget(comp)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,comp,comp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
end
function cm.MokouRebornOperation(exop,excon,comp)
return function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetMZoneCount(tp)<=0 then return end
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,comp,comp) then return end
	if Duel.SpecialSummon(c,0,tp,tp,comp,comp,POS_FACEUP)>0 and exop and (not excon or excon(e,tp,eg,ep,ev,re,r,rp)) then
		exop(e,tp,eg,ep,ev,re,r,rp)
	end
	if comp then c:CompleteProcedure() end
end
end
--code lists
cm.csetlist={
"elem",
"sawawa",
"prism",
"prim",
"3L",
"sayuri",
}
function cm.cgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.cgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function cm.cgfilter(c)
	return cm.unifilter(c) and c:IsFaceup()
end
function cm.unifilter(c)
	if not c:IsType(TYPE_MONSTER) then return false end
	if c:IsCode(210765765) then return true end
	for i,v in pairs(cm.csetlist) do
		local chkf=cm["check_set_"..v]
		if chkf(c) then return true end
	end
	return false
end
--rm mat cost
function cm.RemoveOverlayCost(ct)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
end
--discard hand cost
function cm.DiscardHandCost(ct,f,...)
	local ext_params={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(cm.DiscardHandCostFilter,tp,LOCATION_HAND,0,ct,e:GetHandler(),f,ext_params) end
		Duel.DiscardHand(tp,cm.DiscardHandCostFilter,ct,ct,REASON_COST+REASON_DISCARD,e:GetHandler(),f,ext_params)
	end
end
function cm.DiscardHandCostFilter(c,f,ext_params)
	return c:IsDiscardable() and (not f or f(c,table.unpack(ext_params)))
end
--release cost
function cm.SelfReleaseCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cm.SelfRemoveCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cm.SelfToDeckCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckOrExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function cm.SelfToGraveCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cm.SelfToHandCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
function cm.SelfDiscardCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
--arrival condition
function cm.ArrivalCondition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
---check date dt="Mon" "Tue" etc
function cm.DateCheck(dt,excon)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return dt==os.date("%a") and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
	end
end
--copy effect c=getcard(nil=orcard) tc=sourcecard ht=showcard(bool) res=reset event(nil=no reset)
--ctlm=extra count limit
function cm.CopyStatusAndEffect(e,c,tc,ht,res,resct,ctlm)
		local c=c or e:GetHandler()
		local res=res or RESET_EVENT+0x1fe0000
		local resct=resct or 1
		local cid=nil
		if tc and c:IsFaceup() and c:IsRelateToEffect(e) then
			local code=tc:GetOriginalCode()
			local atk=tc:GetBaseAttack()
			local def=tc:GetBaseDefense()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(res,resct)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(code)
			c:RegisterEffect(e1)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(res,resct)
			e3:SetCode(EFFECT_SET_BASE_ATTACK)
			e3:SetValue(atk)
			c:RegisterEffect(e3)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetReset(res,resct)
			e4:SetCode(EFFECT_SET_BASE_DEFENSE)
			e4:SetValue(def)
			c:RegisterEffect(e4)
			if not tc:IsType(TYPE_TRAPMONSTER) then
				if ctlm then
					cm.CopyEffectExtraCount(c,ctlm,code,res,resct)
				else
					c:CopyEffect(code,res,resct)
				end
			end
			if ht then
				Duel.Hint(HINT_CARD,0,code)
			end
		end
		return cid
end
--copyeffect with extra count limit
function cm.CopyEffectExtraCount(c,ctlm,code,res,resct)
	if not ctlm then return c:CopyEffect(code,res,resct) end
	local et={}
	local ef=Effect.SetCountLimit
	local rf=Card.RegisterEffect
	Effect.SetCountLimit=cm.replace_set_count_limit(et)
	Card.RegisterEffect=cm.replace_register_effect(et,ctlm,ef,rf)
	c:RegisterFlagEffect(210765768,res,0,resct,ctlm)
	local cid=c:CopyEffect(code,res,resct)
	Effect.SetCountLimit=ef
	Card.RegisterEffect=rf
	c:ResetFlagEffect(210765768)
	return cid
end
function cm.replace_set_count_limit(et)
return function(e,ct,cd)
	et[e]={ct,cd}
end
end
function cm.replace_register_effect(et,ctlm,ef,rf)
return function(c,e,forced)
	local t=et[e]   
	if t then
		if e:IsHasType(0x7e0) then
			t[1]=math.max(t[1],ctlm)
		end
		ef(e,table.unpack(t))
	end
	rf(c,e,forced)
end
end

--universals for sww

--swwss(ct=discount exf=extra function)
function cm.SawawaCommonEffect(c,ct,ctxm,ctsm,exf)
	--cm.setreg(c,nil,210765299)
	if ctxm then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
	if ctsm then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetValue(1)
		c:RegisterEffect(e3)
	end
	--ss
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(210765765,0)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e4:SetCost(cm.SawawaSpsummonCost(ct,exf))
	e4:SetTarget(cm.SelfSpsummonTarget)
	e4:SetOperation(cm.SelfSpsummonOperation)
	c:RegisterEffect(e4)
	return e4
end
function cm.SawawaSpsummonCost(ct,exf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			   if e:GetHandler():IsLocation(LOCATION_HAND) and Duel.IsPlayerAffectedByEffect(tp,210765218) then return true end
			   if chk==0 then return Duel.IsExistingMatchingCard(cm.SawawaSpsummonCostFilter,tp,LOCATION_HAND,0,ct,e:GetHandler(),e,exf) end
			   Duel.DiscardHand(tp,cm.SawawaSpsummonCostFilter,ct,ct,REASON_COST,e:GetHandler(),e,exf)
		   end
end
function cm.SelfSpsummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.SelfSpsummonOperation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function cm.SawawaSpsummonCostFilter(c,e,exf)
	return (cm.check_set_sawawa(c) or (exf and exf(c))) and not c:IsCode(e:GetHandler():GetOriginalCode()) and c:IsAbleToGraveAsCost()
end
--for judge blank extra
function cm.CheckNoExtra(e,tp)
	tp=tp or e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
--for sww rm grave
function cm.SawawaRemoveCostFilter(c)
	return cm.check_set_sawawa(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cm.SawawaRemoveCost(ct)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			   if chk==0 then return Duel.IsExistingMatchingCard(cm.SawawaRemoveCostFilter,tp,LOCATION_GRAVE,0,ct,nil) end
			   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			   local g=Duel.SelectMatchingCard(tp,cm.SawawaRemoveCostFilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
			   Duel.Remove(g,POS_FACEUP,REASON_COST)
		   end
end

--universals for bm

--bmss ctg=category istg=is-target-effect

function cm.PrismCommonEffect(c,tg,op,istg,ctg)
	--cm.setreg(c,nil,210765573)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210765765,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCost(cm.PrismSpsummonCost(c:GetOriginalCode()))
	e4:SetTarget(cm.PrismSpsummonTarget)
	e4:SetOperation(cm.PrismSpsummonOperation)
	c:RegisterEffect(e4)
	local e1=nil
	if op then
		e1=Effect.CreateEffect(c)
		if ctg then e1:SetCategory(ctg) end
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)  
		if istg then
			e1:SetProperty(EFFECT_FLAG_CARD_TARGET+cm.delay)
		else
			e1:SetProperty(cm.delay)
		end
		e1:SetCondition(cm.PrismSpsummonCheck)
		if tg then e1:SetTarget(tg) end
		e1:SetOperation(op)
		c:RegisterEffect(e1)
	end
	return e1
end
function cm.PrismSpsummonFilter(c,tp)
	return c:IsAbleToHand() and cm.CheckPrism(c) and c:IsFaceup() and Duel.GetMZoneCount(tp,c,tp)>0
end
function cm.PrismSpsummonCost(cd)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if not cd then return false end
	if chk==0 then return Duel.GetFlagEffect(tp,cd)==0 end
	Duel.RegisterFlagEffect(tp,cd,RESET_PHASE+PHASE_END,0,1)
end
end
function cm.PrismSpsummonTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cm.PrismSpsummonFilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingTarget(cm.PrismSpsummonFilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.PrismSpsummonFilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.PrismSpsummonOperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP) then
				e:GetHandler():RegisterFlagEffect(210765499,RESET_EVENT+0x1fe0000,0,1)
				Duel.SpecialSummonComplete()
			end
		end
	end
end
function cm.PrismSpsummonCheck(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(210765499)>0
end
--check if is bm
function cm.CheckPrism(c)
	return cm.check_set_prism(c) and c:IsType(TYPE_MONSTER)
end
--for condition of damchk
function cm.PrismDamageCheckCondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
--damage chk for bm
--1=remove 2=extraattack 3=atk3000 4=draw
function cm.PrismDamageCheckOperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	local ct=e:GetLabel()
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if ct==0 then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local exte={c:IsHasEffect(210765427)}
		for _,te in ipairs(exte) do
			if Duel.SelectEffectYesNo(tp,te:GetHandler()) then
				Duel.Hint(HINT_CARD,0,te:GetHandler():GetOriginalCode())
				ct=ct+1
			end
		end
		Duel.ConfirmDecktop(tp,ct)
		local g=Duel.GetDecktopGroup(tp,ct)
		local ag=g:Filter(cm.CheckPrism,nil)
		if #ag>0 then
			local val={0}
			for tc in aux.Next(ag) do
				val[1]=val[1]+tc:GetTextAttack()
				if tc.bm_check_operation and (not tc.bm_check_condition or tc.bm_check_condition(e,tp,eg,ep,ev,re,r,rp)) then
					Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
					tc.bm_check_operation(e,tp,eg,ep,ev,re,r,rp,val)
				end
			end
			if val[1]>0 and c:IsRelateToBattle() then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(0x1fe1000+RESET_PHASE+PHASE_DAMAGE_CAL)
				e1:SetValue(val[1])
				c:RegisterEffect(e1)
			end
			if Duel.SelectYesNo(tp,aux.Stringid(210765765,2)) then
				local thg=ag:Filter(cm.PrismCheckAddHand,nil)
				if #thg>0 then
					local thc=thg:Select(tp,1,1,nil)
					Duel.SendtoHand(thc,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,thc)
				end
			end
		end
		Duel.ShuffleDeck(tp)
	end
end
function cm.PrismCheckAddHand(c)
	return c:IsAbleToHand() and c:IsLocation(LOCATION_DECK)
end
--bm attack oppolimit
function cm.PrismDamageCheckRegister(c,lm)
	local e2=nil
	if lm then
		e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,1)
		e2:SetValue(cm.PrismActivateLimit)
		e2:SetCondition(cm.PrismAttackCondition)
		c:RegisterEffect(e2)
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(cm.PrismExtraAttackCount)
	c:RegisterEffect(e4)
	return e4,e2
end
function cm.PrismActivateLimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function cm.PrismAttackCondition(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function cm.PrismExtraAttackCount(e,c)
	return c:GetFlagEffect(210765498)
end
--for cost of rmex
function cm.PrismRemoveExtraCostFilter(c)
	return cm.CheckPrism(c) and c:IsAbleToRemoveAsCost()
end
function cm.PrismRemoveExtraCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.PrismRemoveExtraCostfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.PrismRemoveExtraCostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)

end
--for release bm L5
--fr=must be ssed
function cm.PrismAdvanceCommonEffect(c,fr)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210765765,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cm.PrismProcCondition)
	e1:SetOperation(cm.PrismProcOperation)
	c:RegisterEffect(e1)
	if fr then
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SPSUMMON_CONDITION)
		c:RegisterEffect(e2)
	end
	return e1
end
function cm.PrismProcFilter(c,tp)
	return cm.CheckPrism(c) and Duel.GetMZoneCount(tp,c,tp)>0
end
function cm.PrismProcCondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,cm.PrismProcFilter,1,nil,tp)
end
function cm.PrismProcOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,cm.PrismProcFilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
--prism xyz multi-count xyz proc
function cm.PrismXyzProcedure(c,min,max)
	cm.AddXyzProcedureCustom(c,cm.PrismXyzFilter,cm.PrismXyzCheck(min,max),1,max)	
end
function cm.PrismXyzFilter(c,xyzc)
	return c:IsXyzLevel(xyzc,3) and cm.check_set_prism(c)
end
function cm.PrismXyzCheck(min,max)
	return function(g)
		for i=min,math.min(max,#g*2) do
			if g:CheckWithSumEqual(cm.PrismXyzValue,i,#g,#g) then return true end
		end
		return false
	end
end
function cm.PrismXyzValue(c)
	local v=1
	if c:IsHasEffect(210765499) then v=(v | 0x20000) end
	return v
end
--xyz monster atk drain effect
--con(usual)=condition tg(battledcard,card)=filter
--cost=cost
--xm=drain mat
function cm.AttackOverlayDrainEffect(c,con,tg,cost,ctlm,ctlmid,xm)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_START)
	if ctlm then e5:SetCountLimit(ctlm,ctlmid) end
	e5:SetCondition(cm.AttackOverlayDrainCondition(con,tg))
	if cost then e5:SetCost(cost) end
	e5:SetTarget(cm.AttackOverlayDrainTarget)
	e5:SetOperation(cm.AttackOverlayDrainOperation(xm))
	c:RegisterEffect(e5)
end
function cm.AttackOverlayDrainCondition(con,tg)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local bc=c:GetBattleTarget()
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and bc and (not tg or tg(bc,c)) and not bc:IsType(TYPE_TOKEN) and bc:IsAbleToChangeControler()
	end
end
function cm.AttackOverlayDrainTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
end
function cm.AttackOverlayDrainOperation(xm)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=c:GetBattleTarget()
		if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
			cm.OverlayCard(c,tc,xm)
		end
	end
end
--nanahira parts
function cm.Nanahira(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e2:SetValue(210765765)
	c:RegisterEffect(e2)
end
function cm.NanahiraPendulum(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e2:SetValue(210765765)
	c:RegisterEffect(e2)
	local e6=e2:Clone()
	e6:SetRange(LOCATION_PZONE)
	c:RegisterEffect(e6)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(cm.DescriptionInNanahira(8))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,10000000)
	e1:SetCondition(cm.PendConditionNanahira())
	e1:SetOperation(cm.PendOperationNanahira())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--register by default
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1160)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	c:RegisterEffect(e2)
end
function cm.NanahiraExtraPendulum(c,scon)
	cm.NanahiraPendulum(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNSUMMONABLE_CARD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REVIVE_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(function(e)
		if e:GetHandler():IsLocation(LOCATION_EXTRA) and e:GetHandler():IsFaceup() then return false end
		return true
	end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(function(e,se,sp,st)
		if scon and not scon(e,se,sp,st) then return false end
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_FUSION) and (st & SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION then return false end
		return c:IsHasEffect(EFFECT_REVIVE_LIMIT) or c:IsStatus(STATUS_PROC_COMPLETE) or (st & SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
	end)
	c:RegisterEffect(e2)
end
function cm.PConditionFilterNanahira(c,e,tp,lscale,rscale,f,tc)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and not c:IsForbidden() and (not f or f(c,tc))
end
function cm.PendConditionNanahira()
	return  function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				local rpz=cm.GetPendulumCard(tp,1)
				if rpz==nil or c==rpz then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetUsableMZoneCount(tp)
				if ft<=0 then return false end
				local mft=Duel.GetMZoneCount(tp)
				local eft=Duel.GetLocationCountFromEx(tp)
				local g=nil
				if og then
					g=og:Filter(aux.PConditionFilter,1,nil,e,tp,lscale,rscale)
				else
					g=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,lscale,rscale)
				end
				local ext1={c:IsHasEffect(210765541)}
				local ext2={rpz:IsHasEffect(210765541)} 
				for i,te in pairs(ext1) do
					local t=cm.order_table[te:GetValue()]
					if (t.location==LOCATION_EXTRA and eft>0) or (t.location~=LOCATION_EXTRA and mft>0) then
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te:GetHandler())
						g:Merge(exg)
					end
				end
				for i,te in pairs(ext2) do
					local t=cm.order_table[te:GetValue()]
					if (t.location==LOCATION_EXTRA and eft>0) or (t.location~=LOCATION_EXTRA and mft>0) then
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te:GetHandler())
						g:Merge(exg)
					end
				end
				if mft<=0 then g=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA) end
				if eft<=0 then g:Remove(Card.IsLocation,nil,LOCATION_EXTRA) end
				return #g>0
			end
end
function cm.PendCheckNanahira(g,mft,maxlist)
	if mft>0 and g:IsExists(Card.IsLocation,mft+1,nil,0xbf) then return false end
	for loc,lct in pairs(maxlist) do
		if lct>0 and g:IsExists(Card.IsLocation,lct+1,nil,loc) then return false end
	end
	return true
end
function cm.PendOperationNanahira()
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=cm.GetPendulumCard(tp,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetUsableMZoneCount(tp)
				local mft=Duel.GetMZoneCount(tp)
				local eft=Duel.GetLocationCountFromEx(tp)
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then
					mft=math.min(1,mft)
					mft=math.min(1,eft)
					ft=1
				end
				local tg=nil
				local maxlist={}
				if og then
					tg=og:Filter(aux.PConditionFilter,1,nil,e,tp,lscale,rscale)
				else
					tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,lscale,rscale)
				end
				local ext1={c:IsHasEffect(210765541)}
				local ext2={rpz:IsHasEffect(210765541)}
				for i,te in pairs(ext1) do
					local t=cm.order_table[te:GetValue()]
					if (t.location==LOCATION_EXTRA and eft>0) or (t.location~=LOCATION_EXTRA and mft>0) then
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te:GetHandler())
						tg:Merge(exg)
						local mct=t.max_count
						if mct and mct>0 and mct<ft then
							maxlist[t.location]=mct
						end
					end
				end
				for i,te in pairs(ext2) do
					local t=cm.order_table[te:GetValue()]
					if (t.location==LOCATION_EXTRA and eft>0) or (t.location~=LOCATION_EXTRA and mft>0) then
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te:GetHandler())
						tg:Merge(exg)
						local mct=t.max_count
						if mct and mct>0 and mct<ft then
							maxlist[t.location]=mct
						end
					end
				end
				if mft<=0 then tg=tg:Filter(Card.IsLocation,nil,LOCATION_EXTRA) end
				if eft<=0 then tg:Remove(Card.IsLocation,nil,LOCATION_EXTRA) end
				local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and math.min(c29724053[tp],eft) or eft
				local left=maxlist[LOCATION_EXTRA]
				if left then
					maxlist[LOCATION_EXTRA]=math.min(left,ect)
				else
					maxlist[LOCATION_EXTRA]=ect
				end
				local g=cm.SelectGroup(tp,HINTMSG_SPSUMMON,tg,cm.PendCheckNanahira,nil,1,ft,mft,maxlist)
				sg:Merge(g)
				Duel.HintSelection(Group.FromCards(c))
				Duel.HintSelection(Group.FromCards(rpz))
			end
end
function cm.NanahiraPCardFilter(c)
	return c.Senya_desc_with_nanahira
end
function cm.NanahiraPCardCheck(e)
	return Duel.IsExistingMatchingCard(cm.NanahiraPCardFilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
function cm.NanahiraExistingCondition(og)
return function(e,tp)
	tp=tp or e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cm.NanahiraFilter,tp,LOCATION_ONFIELD,0,1,nil,og)
end
end
function cm.NanahiraFilter(c,og)
	if not c:IsFaceup() then return false end
	return c:GetOriginalCode()==210765765 or (c:IsCode(210765765) and not og)
end
function cm.NanahiraTrap(c,...)
	local t={...}
	for i,te in pairs(t) do
		local e1=te:Clone()
		if te:GetDescription()==0 then
			e1:SetDescription(210765553*16)
		end
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetRange(LOCATION_MZONE)
		if te:GetCode()==EVENT_FREE_CHAIN then
			e1:SetHintTiming(0x1e0)
		end
		e1:SetCost(cm.SelfReleaseCost)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
			return e:GetHandler():IsSummonType(0x553)
		end)
		local op=te:GetOperation()
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			e:GetHandler():ReleaseEffectRelation(e)
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end)
		c:RegisterEffect(e1)
	end
end
--for infinity negate effect
function cm.NegateEffectModule(c,lmct,lmcd,cost,excon,exop,loc,force)
	local e3=Effect.CreateEffect(c)
	local loc=loc or LOCATION_MZONE
	e3:SetDescription(aux.Stringid(210765765,5))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	if force then
		e3:SetType(EFFECT_TYPE_QUICK_F)
	else
		e3:SetType(EFFECT_TYPE_QUICK_O)
	end
	e3:SetCode(EVENT_CHAINING)
	if lmct then e3:SetCountLimit(lmct,lmcd) end
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(loc)
	e3:SetCondition(cm.NegateEffectCondition(excon))
	if cost then e3:SetCost(cost) end
	e3:SetTarget(cm.NegateEffectTarget)
	e3:SetOperation(cm.NegateEffectOperation(exop))
	c:RegisterEffect(e3)
	return e3
end
function cm.NegateEffectCondition(excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.NegateEffectTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cm.NegateEffectOperation(exop)
return function(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		if exop then
			exop(e,tp,eg,ep,ev,re,r,rp)
		end
	end   
end
end
function cm.NegateEffectTrap(c,lmct,lmcd,cost,excon,exop)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(lmct,lmcd)
	e1:SetCondition(cm.NegateEffectCondition(excon))
	if cost then e1:SetCost(cost) end
	e1:SetTarget(cm.NegateEffectTarget)
	e1:SetOperation(cm.NegateEffectOperation(exop))
	c:RegisterEffect(e1)
	return e1
end
function cm.DrawTarget(ct)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
end
function cm.DrawOperation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cm.PrimSynchroFilter(c)
	return cm.check_set_prim(c) and c:IsSynchroType(TYPE_SYNCHRO)
end
function cm.PrimLv4CommonEffect(c,cd)
	aux.AddSynchroProcedure(c,nil,cm.check_set_prim,1)
	c:EnableReviveLimit()
end
function cm.XMaterialCountCondition(ct,excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=ct and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
--counter summon effect universals
--n=normal f=flip s=special o=opponent only
function cm.NegateSummonModule(c,tpcode,ctlm,ctlmid,con,cost)
	if not tpcode or (tpcode & 7)==0 then return end
	ctlmid=ctlmid or 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210765765,4))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
	if (tpcode & 8)==8 then
		e3:SetLabel(2)
	else
		e3:SetLabel(1)
	end
	e3:SetCondition(cm.NegateSummonCondition(con))
	if cost then e3:SetCost(cost) end
	e3:SetTarget(cm.NegateSummonTarget)
	e3:SetOperation(cm.NegateSummonOperation)
	local e2=e3:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	local e1=e3:Clone()
	e1:SetCode(EVENT_SUMMON)
	local t={}
	if (tpcode & 1)==1 then
		c:RegisterEffect(e1)
		table.insert(t,e1)
	end
	if (tpcode & 2)==2 then
		c:RegisterEffect(e2)
		table.insert(t,e2)
	end
	if (tpcode & 4)==4 then
		c:RegisterEffect(e3)
		table.insert(t,e3)
	end
	return table.unpack(t)
end
function cm.NegateSummonFilter(c,tp,e)
	return c:GetSummonPlayer()==tp or e:GetLabel()==1
end
function cm.NegateSummonCondition(con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and eg:IsExists(cm.NegateSummonFilter,1,nil,e,1-tp) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.NegateSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cm.filter,nil,e,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function cm.NegateSummonOperation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cm.NegateSummonFilter,nil,e,1-tp)
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end
--for copying spell
function cm.CopySpellModule(c,loc1,loc2,f,con,cost,ctlm,ctlmid,eloc,x)
	local e2=Effect.CreateEffect(c)
	eloc=eloc or LOCATION_MZONE
	ctlmid=ctlmid or 1
	e2:SetDescription(aux.Stringid(210765765,6))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(eloc)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0x3c0)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	if ctlm then e2:SetCountLimit(ctlm,ctlmid) end
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.CheckEvent(EVENT_CHAINING) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
	end)
	e2:SetCost(cm.ForbiddenCost(cost))
	e2:SetTarget(cm.CopySpellNormalTarget(loc1,loc2,f,x))
	e2:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210765765,6))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
	e3:SetCost(cm.ForbiddenCost(cost))
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not con or con(e,tp,eg,ep,ev,re,r,rp)
	end)
	e3:SetTarget(cm.CopySpellChainingTarget(loc1,loc2,f,x))
	e3:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e3)
	return e2,e3
end
function cm.ForbiddenCost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(1)
		if not costf then return true end
		return costf(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function cm.CopySpellNormalFilter(c,f,e,tp)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) 
		and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false) and (not f or f(c,e,tp))
end
function cm.CopySpellNormalTarget(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.CopySpellNormalFilter,1,nil,f,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.CopySpellNormalFilter,1,1,nil,f,e,tp)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
end
function cm.CopyOperation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if te:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cm.CopySpellChainingFilter(c,e,tp,eg,ep,ev,re,r,rp,f)
	if (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) and c:IsAbleToRemoveAsCost() and (not f or f(c,e,tp,eg,ep,ev,re,r,rp)) then
		if c:CheckActivateEffect(true,true,false) then return true end
		local te=c:GetActivateEffect()
		if te:GetCode()~=EVENT_CHAINING then return false end
		local tg=te:GetTarget()
		if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then return false end
		return true
	else return false end
end
function cm.CopySpellChainingTarget(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.CopySpellChainingFilter,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.CopySpellChainingFilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	local tc=g:GetFirst()
	local te,ceg,cep,cev,cre,cr,crp
	local fchain=cm.CopySpellNormalFilter(tc)
	if fchain then
		te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	else
		te=tc:GetActivateEffect()
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(te:GetLabel())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		if fchain then
			tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		else
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
end
function cm.InstantCopyModule(c,lmct,lmcd,cost,excon,loc)
	local e3=Effect.CreateEffect(c)
	loc=loc or LOCATION_MZONE
	e3:SetDescription(aux.Stringid(210765765,7))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	if lmct then e3:SetCountLimit(lmct,lmcd) end
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(loc)
	e3:SetCondition(cm.InstantCopyCondition(excon))
	e3:SetCost(cm.ForbiddenCost(cost))
	e3:SetTarget(cm.InstantCopyTarget)
	e3:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e3)
	return e3
end
function cm.InstantCopyCondition(excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.InstantCopyTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local te=re:Clone()
	local tg=te:GetTarget()
	local code=te:GetCode()
	local tres,teg,tep,tev,tre,tr,trp
	if code>0 and code~=EVENT_FREE_CHAIN and code~=EVENT_CHAINING and Duel.CheckEvent(code) then
		tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(code,true)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		local res=false
		if not tg then return true end
		if not pcall(function()
			if tres then res=tg(e,tp,teg,tep,tev,tre,tr,trp,0)
			else res=tg(e,tp,eg,ep,ev,re,r,rp,0) end
		end) then return false end
		return res
	end
	e:SetLabel(te:GetLabel())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then
		if tres then
			tg(e,tp,teg,tep,tev,tre,tr,trp,1)
		else
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
function cm.NegateEffectWithoutChainingModule(c,con,cost,exop,desc,des,loc)
	local e3=Effect.CreateEffect(c)
	loc=loc or LOCATION_MZONE
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(loc)
	e3:SetCondition(cm.NegateEffectWithoutChainingCondition(con))
	e3:SetOperation(cm.NegateEffectWithoutChainingOperation(cost,exop,desc,des))
	c:RegisterEffect(e3)
	return e3
end
function cm.NegateEffectWithoutChainingCondition(con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainDisablable(ev) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.NegateEffectWithoutChainingOperation(cost,exop,desc,des)
return function(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,desc) then return end
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
	if cost then cost(e,tp,eg,ep,ev,re,r,rp) end
	local chk=Duel.NegateEffect(ev)
	if re:GetHandler():IsRelateToEffect(re) and des then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
	if chk and exop then
		exop(e,tp,eg,ep,ev,re,r,rp)
	end
end
end
--for aux.FCheckAdditional in izayoi
function cm.CheckFusionMaterialExact(c,g,chkf)
	aux.FCheckAdditional=cm.HoldGroup(g)
	local res=c:CheckFusionMaterial(g,nil,chkf)
	aux.FCheckAdditional=nil
	return res
end
function cm.HoldGroup(mg)
	return function(tp,g,fc)
		return mg:Equal(g)
	end
end
--3L fusion monster, c=card, m=code
--exf=extra function
function cm.Fusion_3L(c,mf,f,min,max,myon,sub)
	cm.enable_kaguya_check_3L()
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.FusionCondition_3L(mf,f,min,max,myon,sub))
	e1:SetOperation(cm.FusionOperation_3L(mf,f,min,max,myon,sub))
	c:RegisterEffect(e1)
end
function cm.MyonCheckFilter(c,ec,myon)
	return (c:IsHasEffect(210765841) or myon) and c:IsFaceup() and c:IsCanBeFusionMaterial(ec)
end
function cm.FusionFilter_3L(c,fc,mf,sub)
	return c:IsCanBeFusionMaterial(fc) and not c:IsHasEffect(6205579) and ((not mf or mf(c,fc,sub)) or c:IsHasEffect(210765914))
end
function cm.FusionCheck_3L(g,min,tp,fc,f,chkf,sub)
		--check sayuri_3L
	if g:IsExists(aux.TuneMagicianCheckX,nil,g,EFFECT_TUNE_MAGICIAN_F) then return false end
	if chkf~=PLAYER_NONE and Duel.GetLocationCountFromEx(chkf,tp,g,fc)<=0 then return false end
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,g,fc) then return false end
	if #g==1 and fc:GetLevel()==7 and g:GetFirst():IsHasEffect(210765914) then return true end
	return #g>=min and (not f or f(g,fc,sub))
end
function cm.FusionCondition_3L(mf,f,min,max,myon,sub)
return function(e,g,gc,chkfnf)
	if g==nil then return true end
	local c=e:GetHandler()
	local chkf=(chkfnf & 0xff)
	local mg=g:Filter(cm.FusionFilter_3L,nil,e:GetHandler(),mf,sub)
	local tp=e:GetHandlerPlayer()
	local exg=Duel.GetMatchingGroup(cm.MyonCheckFilter,tp,0,LOCATION_MZONE,nil,c,myon)
	mg:Merge(exg)
	local sg=Group.CreateGroup()
	if gc then
		if not cm.FusionFilter_3L(gc,fc,mf,sub) then return false end
		sg:AddCard(gc)
	end
	local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_FMATERIAL)}
	for _,te in ipairs(ce) do
		local tc=te:GetHandler()
		if not mg:IsContains(tc) then return false end
		sg:AddCard(tc)
	end
	return cm.CheckGroup(mg,cm.FusionCheck_3L,sg,1,max,min,tp,c,f,chkfnf,sub)
end
end
function cm.FusionOperation_3L(mf,f,min,max,myon,sub)
return function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
	local c=e:GetHandler()
	local chkf=(chkfnf & 0xff)
	local mg=eg:Filter(cm.FusionFilter_3L,nil,e:GetHandler(),mf,sub)
	local exg=Duel.GetMatchingGroup(cm.MyonCheckFilter,tp,0,LOCATION_MZONE,nil,c,myon)
	mg:Merge(exg)
	local sg=Group.CreateGroup()
	if gc then
		sg:AddCard(gc)
	end
	local ce={Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_FMATERIAL)}
	for _,te in ipairs(ce) do
		local tc=te:GetHandler()
		sg:AddCard(tc)
	end
	local g=cm.SelectGroup(tp,HINTMSG_FMATERIAL,mg,cm.FusionCheck_3L,sg,1,max,min,tp,c,f,chkf,sub)
	Duel.SetFusionMaterial(g)
end
end
function cm.GroupFilterMultiCheck(c,g,list,ct,fc,sub)
	local f=list[ct]
	if not f(c,fc,sub) then return false end
	if ct==#list then return true end
	local res=false
	g:RemoveCard(c)
	if sub and f(c,fc,false) then
		res=g:IsExists(cm.GroupFilterMultiCheck,1,nil,g,list,ct+1,fc,true)
	else
		res=g:IsExists(cm.GroupFilterMultiCheck,1,nil,g,list,ct+1,fc,false)
	end
	g:AddCard(c)
	return res
end
function cm.GroupFilterMulti(...)
	local list={...}
	return function(g,fc,sub)
		return g:IsExists(cm.GroupFilterMultiCheck,1,nil,g,list,1,fc,sub)
	end
end
function cm.AttributeReplace_3L(att)
	return function(c)
		return c:IsFusionAttribute(att) or c:IsHasEffect(210765828)
	end
end
function cm.Fusion_3L_Attribute(c,mt)
	local f1=cm.check_fusion_set_3L
	local f2=cm.AttributeReplace_3L(mt.fusion_att_3L)
	return cm.Fusion_3L(c,cm.OR(f1,f2),cm.GroupFilterMulti(f1,f2),2,2)
end
function cm.GainEffectFilter(c,fc)
	if not c.effect_operation_3L then return false end
	local con=c.effect_condition_3L
	if con and not con(c,fc) then return false end
	return true
end
function cm.FusionGainFilter(c)
	local t=cm.gain_effect_list_3L[c]
	return c:IsSummonType(SUMMON_TYPE_FUSION) and t and c:GetFlagEffect(210765848)==0
end
function cm.enable_kaguya_check_3L()
	if cm.kaguya_check_3L then return end
	cm.kaguya_check_3L={}
	cm.previous_chain_info={}
	cm.kaguya_check_3L[0]=0
	cm.kaguya_check_3L[1]=0
	cm.gain_effect_list_3L={}
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		cm.kaguya_check_3L[ep]=cm.kaguya_check_3L[ep]+1
		if cm.kaguya_check_3L[ep]==7 then
			Duel.RaiseEvent(eg,EVENT_CUSTOM+210765829,re,r,rp,ep,ev)
		end
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		local ceg=eg:Clone()
		ceg:KeepAlive()
		cm.previous_chain_info[cid]={ceg,ep,ev,re,r,rp}
	end)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e2:SetOperation(function()
		cm.kaguya_check_3L[0]=0
		cm.kaguya_check_3L[1]=0
	end)
	Duel.RegisterEffect(e2,0)
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(cm.FusionGainFilter,1,nil)
	end)
	ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=eg:Filter(cm.FusionGainFilter,nil)
		for tc in aux.Next(g) do
			local t=cm.gain_effect_list_3L[tc]
			for code,v in pairs(t) do
				cm.GainEffect_3L(tc,code)
			end
		end
	end)
	Duel.RegisterEffect(ge1,0)
	local ge3=Effect.GlobalEffect()
	ge3:SetType(EFFECT_TYPE_FIELD)
	ge3:SetCode(EFFECT_MATERIAL_CHECK)
	ge3:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	ge3:SetTargetRange(0xff,0xff)
	ge3:SetValue(function(e,c)
		if c:IsType(TYPE_FUSION) and cm.check_set_3L(c) then
			local g=c:GetMaterial():Filter(cm.GainEffectFilter,nil,c)
			local t={}
			for tc in aux.Next(g) do
				t[tc:GetOriginalCode()]=true
			end
			cm.gain_effect_list_3L[c]=t
		end
	end)
	Duel.RegisterEffect(ge3,0)
end
function cm.CheckKoishiCount(c)
	local t={c:IsHasEffect(210765826)}
	local res=1
	for i,te in pairs(t) do
		res=math.max(res,te:GetValue())
	end
	return res
end
--filter for effect gaining
--chkc=card to check if it can gain c's effect, nil for not checking
function cm.EffectSourceFilter_3L(c,chkc)
	local cd=c:GetOriginalCode()
	local mt=cm.LoadMetatable(cd)
	return cm.check_set_3L(c) and c:IsType(TYPE_MONSTER) and mt and mt.effect_operation_3L and (not chkc or chkc:GetFlagEffect(cd-4000)==0)
end
--3L get effect by other cards
--c=target_card, tc=source_card/code, pres=reset on the next turn, pctlm=count_limit(before custom_ctlm_3L)
function cm.GainEffect_3L(c,tc,pres,pctlm)
	local cd=0
	if type(tc)=="number" then
		cd=tc
	else
		cd=tc:GetOriginalCode()
	end
	local mt=cm.LoadMetatable(cd)
	if not mt or c:GetFlagEffect(cd-4000)>0 or not mt.effect_operation_3L then return end
	local ctlm=pctlm or cm.CheckKoishiCount(c)
	local efft={mt.effect_operation_3L(c,ctlm)}
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e2,true)
	table.insert(efft,e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(EFFECT_NORMAL)
	c:RegisterEffect(e3,true)
	table.insert(efft,e3)	
	c:RegisterFlagEffect(cd-4000,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,cm.order_table_new(efft),cd*16+1)
	if pres then
		local info_list={
			elist=efft,
			code=cd,
		}
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(pres)
		e1:SetCondition(function(e)
			local tc=e:GetOwner()
			local effm=tc:GetFlagEffectLabel(info_list.code-4000)
			if not effm then e:Reset() return false end
			local efft=cm.order_table[effm]
			if efft~=info_list.elist then e:Reset() return false end
			return true
		end)
		e1:SetOperation(function(e)
			local tct=e:GetLabel()-1
			if tct>0 then
				e:SetLabel(tct)
			else
				cm.RemoveCertainEffect_3L(e:GetOwner(),info_list.code)
				e:Reset()
			end
		end)
		Duel.RegisterEffect(e1,c:GetControler())
	end
	return efft
end
--create the codelist for checking effects
if not cm.codelist_3L then
	cm.codelist_3L={210765519,210765914}
	for i=210765800,210765899 do
		table.insert(cm.codelist_3L,i)
	end
end
--returns a table, which shows all the codes the effect c gets
function cm.GetGainedList_3L(c)
	local t={}
	for i,code in pairs(cm.codelist_3L) do
		if c:GetFlagEffect(code-4000)>0 then
			table.insert(t,code)
		end
	end
	return t
end
--returns the effect_count of the effect tc gets
function cm.GetGainedCount_3L(c)
	local t=cm.GetGainedList_3L(c)
	local v=0
	for i,cd in pairs(t) do
		local mt=cm.LoadMetatable(cd)
		local mct=mt.custom_effect_count_3L or 1
		v=v+mct
	end
	return v
end
--reset gained effect from 3L
function cm.RemoveCertainEffect_3L(tc,code)
	local effm=tc:GetFlagEffectLabel(code-4000)
	if not effm then return false end
	local mt=cm.LoadMetatable(code)
	Duel.Hint(tc:GetControler(),HINT_OPSELECTED,cm.DescriptionInNanahira(10))
	local efft=cm.order_table[effm]
	for i,te in pairs(efft) do
		if mt and mt.reset_operation_3L and mt.reset_operation_3L[i] then
			mt.reset_operation_3L[i](te,tc)
		end
		te:Reset()
	end
	tc:ResetFlagEffect(code-4000)
	return true
end
--remove ct~maxct of the effect(s) from 3L
--[...]shows the code omitted
function cm.RemoveEffect_3L(tp,tc,ct,maxct,chk,...)
	local maxct=maxct or ct
	local effect_list=cm.GetGainedList_3L(tc)
	local avaliable_list={}
	local omit_list={...}
	local oet={tc:IsHasEffect(210765827)}
	for i,oe in pairs(oet) do
		local of=cm.order_table[oe:GetValue()]
		local og=of(tc)
		for oc in aux.Next(og) do
			table.insert(omit_list,oc:GetOriginalCode())
		end
	end
	for i,code in pairs(effect_list) do
		local res=true
		for j,ocode in pairs(omit_list) do
			if code==ocode then res=false end
		end
		if res then table.insert(avaliable_list,i) end  
	end
	if chk then return #avaliable_list>=ct end
	local result_count=0
	while #avaliable_list>0 and result_count<maxct and not (result_count>=ct and not Duel.SelectYesNo(tp,210)) do
		local option_list={}
		for i,v in pairs(avaliable_list) do
			local descid=1
			local ccode=effect_list[v]
			local mt=cm.LoadMetatable(ccode)
			local effct=mt.custom_effect_count_3L
			if effct and effct>1 then descid=effct+1 end
			table.insert(option_list,aux.Stringid(ccode,descid))
		end
		Duel.Hint(HINT_SELECTMSG,tp,cm.DescriptionInNanahira(9))
		local option=table.remove(avaliable_list,Duel.SelectOption(tp,table.unpack(option_list))+1)
		cm.RemoveCertainEffect_3L(tc,effect_list[option])
		result_count=result_count+1
	end
	return result_count
end
--cost for self removing effect
--... stands for omit codes
function cm.RemoveEffectCost_3L(ct,...)
local omit_list={...}
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():IsHasEffect(210765827) then return false end
		return cm.RemoveEffect_3L(tp,e:GetHandler(),ct,ct,true,table.unpack(omit_list))
	end
	cm.RemoveEffect_3L(tp,e:GetHandler(),ct,ct,false,table.unpack(omit_list))
end
end

function cm.MergeCost(...)
	local list={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			for _,f in pairs(list) do
				if f and not f(e,tp,eg,ep,ev,re,r,rp,0) then return false end
			end
			return true
		end
		for _,f in pairs(list) do
			if f then f(e,tp,eg,ep,ev,re,r,rp,1) end
		end
	end
end
--registers an effect which gains 3L's effect continuously
--function f stands for the function which returns a group to be gained
--excost is a function which has a card for param and returns an extra cost for gaining effects which are activatable. For ordinary costs, use DirectReturn.
function cm.ContinuousEffectGainModule_3L(c,f,excost)
	local excost=excost or aux.NULL
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cm.ContinuousEffectCondition_3L(f))
	e2:SetOperation(cm.ContinuousEffectOperation_3L(f,excost))
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(210765827)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(cm.order_table_new(f))
	c:RegisterEffect(e3)
end
function cm.ContinuousEffectCondition_3L(f)
	return function(e)
		local c=e:GetHandler()
		return c:IsHasEffect(210765827) and f(c):IsExists(cm.EffectSourceFilter_3L,1,nil,c)
	end
end
function cm.ContinuousEffectOperation_3L(f,excost)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local og=f(c):Filter(cm.EffectSourceFilter_3L,nil,c)
		for tc in aux.Next(og) do
			local t=cm.GainEffect_3L(c,tc,false,63)
			if t then
				for i,te in pairs(t) do
					te:SetCondition(cm.ContinuousEffectReplaceCondition_3L(f,te:GetCondition(),tc:GetOriginalCode()))
					if te:IsHasType(0x7e0) then
						te:SetCost(cm.MergeCost(cm.CountCost_3L(tc:GetOriginalCode(),tc.single_effect_3L),te:GetCost(),excost(tc)))					
					end
				end
			end
		end
	end
end
function cm.ContinuousEffectReplaceCondition_3L(f,con,cd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if (f(c):IsExists(aux.FilterEqualFunction(Card.GetOriginalCode,cd),1,nil) and c:IsHasEffect(210765827)) then
			return (not con or con(e,tp,eg,ep,ev,re,r,rp))
		else
			cm.RemoveCertainEffect_3L(e:GetHandler(),cd)
			return false
		end
	end
end
function cm.CountCost_3L(cd,chks)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chks then return true end
		local c=e:GetHandler()
		local ctlm=cm.CheckKoishiCount(c)
		if chk==0 then return c:GetFlagEffect(cd-3000)<ctlm end
		c:RegisterFlagEffect(cd-3000,0x1fe1000+RESET_PHASE+PHASE_END,0,1)
	end
end
function cm.PreExile(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	local t={EFFECT_CANNOT_TO_DECK,EFFECT_CANNOT_REMOVE,EFFECT_CANNOT_TO_GRAVE}
	for i,code in pairs(t) do
		local ex=e1:Clone()
		ex:SetCode(code)
		c:RegisterEffect(ex,true)
	end
	Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE)
end
function cm.ExileCard(c)
	cm.PreExile(c)
	Duel.Exile(c,REASON_RULE)
	c:ResetEffect(0xfff0000,RESET_EVENT)
end
function cm.ExileGroup(g)
	for c in aux.Next(g) do
		cm.PreExile(c)
	end
	Duel.Exile(g,REASON_RULE)
	for c in aux.Next(g) do
		c:ResetEffect(0xfff0000,RESET_EVENT)
	end
end
function cm.DescriptionCost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end		
	end
end
function cm.splimit(c,v,rlimit)
	if rlimit then
		c:EnableReviveLimit()
	end
	v=v or 0
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_SINGLE)
	e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e22:SetCode(EFFECT_SPSUMMON_CONDITION)
	e22:SetValue(v)
	c:RegisterEffect(e22)
	return e22
end
function cm.splimitcost(f,m,cost,...)
	local ext_params={...}
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(f,...))
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0 and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0)) end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(cm.splimit_filter(f,ext_params))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	end
end
function cm.splimit_filter(f,ext_params)
	return function(e,c)
		return not f(c,table.unpack(ext_params))
	end
end
function cm.multi_choice_target(m,...)
	local function_list={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then
			local pr=e:GetProperty()
			return (pr & EFFECT_FLAG_CARD_TARGET)~=0 and function_list[e:GetLabel()](e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
		local avaliable_list={}
		for i,tg in pairs(function_list) do
			if tg(e,tp,eg,ep,ev,re,r,rp,0) then
				table.insert(avaliable_list,i)
			end
		end
		if chk==0 then return #avaliable_list>0 end
		local option_list={}
		for i,v in pairs(avaliable_list) do
			table.insert(option_list,aux.Stringid(m,v-1))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local option=avaliable_list[Duel.SelectOption(tp,table.unpack(option_list))+1]
		e:SetLabel(option)
		function_list[option](e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function cm.multi_choice_operation(...)
	local function_list={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local op=function_list[e:GetLabel()]
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
--order_table system
--allows storing value of any type by Label or FlagEffectLabel
--cm.order_table_new will create a new space in cm.order_table and returns the address
--usually stores the address in Label and uses them by using the Label as the key to cm.order_table
cm.order_table=cm.order_table or {}
cm.order_count=cm.order_count or 0
function cm.order_table_new(v)
	cm.order_count=cm.order_count+1
	cm.order_table[cm.order_count]=v
	return cm.order_count
end
function cm.enable_get_all_cards()
	if not cm.get_all_cards then
		cm.get_all_cards=Group.CreateGroup()
		cm.get_all_cards:KeepAlive()
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetOperation(function()
			local g=Duel.GetFieldGroup(0,0xff,0xff)
			local g1=g:Clone()
			g:ForEach(function(tc)
				g1:Merge(tc:GetOverlayGroup())
			end)
			cm.get_all_cards:Merge(g1)
		end)
		Duel.RegisterEffect(e1,0)
		return true
	end
	return false
end
function cm.SummonTypeCondition(t,con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(t) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.NonImmuneFilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function cm.FusionMaterialFilter(c,oppo)
	if oppo and c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER)
end
function cm.GetFusionMaterial(tp,loc,oloc,f,gc,e,...)
	local g1=Duel.GetFusionMaterial(tp)
	if loc then
		local floc=(loc & LOCATION_ONFIELD+LOCATION_HAND)
		if floc~=0 then
			g1=g1:Filter(Card.IsLocation,nil,floc)
		else
			g1:Clear()
		end
		local eloc=loc-floc
		if eloc~=0 then
			local g2=Duel.GetMatchingGroup(cm.FusionMaterialFilter,tp,eloc,0,nil)
			g1:Merge(g2)
		end
	end
	if oloc and oloc~=0 then
		local g3=Duel.GetMatchingGroup(cm.FusionMaterialFilter,tp,0,oloc,nil,true)
		g1:Merge(g3)
	end
	if f then g1=g1:Filter(f,nil,...) end
	if gc then g1:RemoveCard(gc) end
	if e then g1=g1:Filter(cm.NonImmuneFilter,nil,e) end
	return g1
end
function cm.GetReleaseGroup(tp,loc,oloc,f,gc,...)
	local g1=Duel.GetReleaseGroup(tp)
	if loc then
		local floc=(loc & LOCATION_MZONE)
		if floc~=0 then
			g1=g1:Filter(Card.IsLocation,nil,floc)
		else
			g1:Clear()
		end
		local eloc=loc-floc
		if eloc~=0 then
			local g2=Duel.GetMatchingGroup(Card.IsReleasable,tp,eloc,0,nil)
			g1:Merge(g2)
		end
	end
	if oloc and oloc~=0 then
		local g3=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,oloc,nil)
		g1:Merge(g3)
	end
	if f then g1=g1:Filter(f,nil,...) end
	if gc then g1:RemoveCard(gc) end
	return g1
end
function cm.ReleaseCost(loc,oloc,f,self,...)
	local ext_params={...}
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
					local ec=self and e:GetHandler()
					local mg=cm.GetReleaseGroup(tp,loc,oloc,f,ec,table.unpack(ext_params))
					if chk==0 then return #mg>0 and (not ec or ec:IsReleasable()) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
					local g=mg:Select(tp,1,1,nil)
					if ec then g:AddCard(ec) end
					Duel.Release(g,REASON_COST)
				end
end
function cm.ChainLimitCost(original_cost)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
					local effect_code=e:GetHandler():GetFlagEffectLabel(210765766)
					if chk==0 then
						if original_cost and not original_cost(e,tp,eg,ep,ev,re,r,rp,0) then return false end
						if not effect_code then return true end
						local effect_list=cm.order_table[effect_code]
						for i,te in pairs(effect_list) do
							if e==te then return false end
						end
						return true
					end
					if original_cost then original_cost(e,tp,eg,ep,ev,re,r,rp,1) end
					if effect_code then
						local effect_list=cm.order_table[effect_code]
						table.insert(effect_list,e)
					else
						e:GetHandler():RegisterFlagEffect(210765766,RESET_EVENT+0x1fe0000+RESET_CHAIN,0,1,cm.order_table_new({e}))
					end
				end
end
function cm.RemainFilter(ct,ignorefaceup)
	if not cm.RemainCheck then
		cm.RemainCheck=true
		local ex=Effect.GlobalEffect()
		ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ex:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ex:SetOperation(cm.RemainCheckOperation)
		Duel.RegisterEffect(ex,0)
	end
	return function(c)
		 return c:GetFlagEffect(210765767)>=ct and (ignorefaceup or c:IsFaceup())
	end
end
function cm.RemainCheckFilter(c)
	return not c:IsType(TYPE_TOKEN)
end
function cm.RemainCheckOperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.RemainCheckFilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:ForEach(function(tc)
		tc:RegisterFlagEffect(210765767,RESET_EVENT+0x1fc0000,0,1)
	end)
end
--for sayuri
cm.sayuri_fit_monster=cm.sayuri_fit_monster or {}
cm.sayuri_activate_effect=cm.sayuri_activate_effect or {}

function cm.SayuriRitualPreload(m)
	local mt=cm.LoadMetatable(m)
	mt.Senya_name_with_sayuri=true
	table.insert(cm.sayuri_fit_monster,m)
	return m,mt
end
function cm.SayuriSpellPreload(m)
	local mt=cm.LoadMetatable(m)
	mt.Senya_name_with_sayuri=true
	mt.fit_monster=cm.sayuri_fit_monster
	return m,mt
end
function cm.SayuriSelfReturnCommonEffect(c,m)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(cm.DescriptionInNanahira(11))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,210765900)
	e2:SetCost(cm.SayuriSelfReturnCost)
	e2:SetTarget(cm.DrawTarget(1))
	e2:SetOperation(cm.DrawOperation)
	c:RegisterEffect(e2)
	return e2
end
function cm.SayuriSelfReturnFilter(c)
	return cm.check_set_sayuri(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.SayuriSelfReturnCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(cm.SayuriSelfReturnFilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cm.SayuriSelfReturnFilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cm.SayuriCheckTrigger(c,e,tp,eg,ep,ev,re,r,rp)
	if not e:IsActiveType(TYPE_RITUAL) then return end
	if not c.sayuri_trigger_operation then return end
	if c.sayuri_trigger_condition and not c:sayuri_trigger_condition(e,tp,eg,ep,ev,re,r,rp) then return end
	if not (c.sayuri_trigger_forced or Duel.SelectEffectYesNo(tp,c)) then return end
	Duel.Hint(HINT_CARD,0,c:GetOriginalCode())
	Duel.BreakEffect()
	c:sayuri_trigger_operation(e,tp,eg,ep,ev,re,r,rp)
end
function cm.SayuriDefaultMaterialFilterLevel8(c)
	if c:GetLevel()==8 and c:IsLocation(LOCATION_GRAVE) then return false end
	return true
end
function cm.SayuriDefaultMaterialFilterLevel12(c)
	return cm.check_set_sayuri(c) and c:GetLevel()==4
end

function cm.CloneTable(t)
	local rt={}
	for i,v in pairs(t) do
		rt[i]=v
	end
	return rt
end
function cm.GetPendulumCard(tp,seq)
	return Duel.GetFieldCard(tp,LOCATION_PZONE,seq)
end
function cm.CheckPendulum(c)
	local tp=c:GetControler()
	return cm.GetPendulumCard(tp,0)==c or cm.GetPendulumCard(tp,1)==c
end
function cm.CheckSummonLocation(c,tp,g)
	local g=g or Group.CreateGroup()
	if c:IsLocation(LOCATION_EXTRA) then return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 end
	return Duel.GetMZoneCount(tp,g,tp)>0
end
function cm.AND(...)
	return aux.AND(...)
end
function cm.OR(...)
	return aux.OR(...)
end
function cm.NOT(f)
	return aux.NOT(f)
end
function cm.DirectReturn(...)
	local t={...}
	return function()
		return table.unpack(t)
	end
end
function cm.GetEffectValue(e,...)
	local v=e:GetValue()
	if type(v)=="function" then
		return v(e,...)
	else
		return v
	end
end
--custom ocgcore needed
function cm.CheckEffect(c,code,...)
	local eset={c:IsHasEffect(code)}
	for _,te in ipairs(eset) do
		local res=cm.GetEffectValue(te,...)
		if res and res~=0 then return res end
	end
	return false
end
function cm.CheckPlayerEffect(p,code,...)
	local eset={Duel.IsPlayerAffectedByEffect(p,code)}
	for _,te in ipairs(eset) do
		local res=cm.GetEffectValue(te,...)
		if res and res~=0 then return res end
	end
	return false
end
function cm.AddSummonMusic(c,desc,stype)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	if stype then
		e1:SetCondition(cm.SummonTypeCondition(stype))
	end
	e1:SetOperation(function()
		Duel.Hint(HINT_MUSIC,0,desc)
	end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function cm.IgnoreActionCheck(f,...)
	Duel.DisableActionCheck(true)
	local cr=coroutine.create(f)
	local ret={}
	while coroutine.status(cr)~="dead" do
		local sret={coroutine.resume(cr,...)}
		for i=2,#sret do
			table.insert(ret,sret[i])
		end
	end
	Duel.DisableActionCheck(false)
	return table.unpack(ret)
end
--no front side common effects
function cm.IsDFCTransformable(c)
	return c.dfc_front_side
end
function cm.GetDFCBackSideCard(c)
	if not cm.IsDFCTransformable(c) then return end
	return cm.IgnoreActionCheck(Duel.CreateToken,c:GetControler(),c.dfc_front_side)
end
function cm.TransformDFCCard(c)
	if not cm.IsDFCTransformable(c) then return false end
	local tcode=c.dfc_front_side
	c:SetEntityCode(tcode,true)
	c:ReplaceEffect(tcode,0,0)
	Duel.SetMetatable(c,_G["c"..tcode])
	Duel.Hint(HINT_CARD,0,tcode)
	Duel.ConfirmCards(c:GetControler(),Group.FromCards(c))
	if c:IsLocation(LOCATION_DECK) then
		Duel.ConfirmCards(1-c:GetControler(),Group.FromCards(c))
	end
	return true
end
function cm.DFCBackSideCommonEffect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND+LOCATION_EXTRA)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c.dfc_back_side
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tcode=c.dfc_back_side
		if not tcode then return end
		c:SetEntityCode(tcode)
		Duel.ConfirmCards(tp,Group.FromCards(c))
		if c:IsLocation(LOCATION_DECK) then
			Duel.ConfirmCards(1-tp,Group.FromCards(c))
		end
		c:ReplaceEffect(tcode,0,0)
		Duel.SetMetatable(c,_G["c"..tcode])
	end)
	c:RegisterEffect(e2)	
	local e3=e2:Clone()
	e3:SetRange(0)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCode(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	c:RegisterEffect(e3)
end
--for ritual update
function cm.CheckRitualMaterialGoal(g,c,tp,lv,f,gt)
	return cm.CheckSummonLocation(c,tp,g) and (g:CheckWithSumEqual(f,lv,#g,#g,c) or (gt and cm.CheckGreaterExact(g,f,lv,c)))
end
function cm.DivideValueMax(f,...)
	local ext_params={...}
	return function(c)
		local v=f(c,table.unpack(ext_params))
		local v1=(v & 0xffff)
		local v2=(v >> 16)
		return math.max(v1,v2)
	end
end
function cm.DivideValueMin(f,...)
	local ext_params={...}
	return function(c)
		local v=f(c,table.unpack(ext_params))
		local v1=(v & 0xffff)
		local v2=(v >> 16)
		if v1<=0 then
			return v2
		elseif v2<=0 then
			return v1
		else
			return math.min(v1,v2)
		end
	end
end
function cm.CheckGreaterExactCounterCheck(c,g,f,lv,...)
	g:RemoveCard(c)
	local res=g:GetSum(cm.DivideValueMin(f,...))>=lv
	g:AddCard(c)
	return res
end
function cm.CheckGreaterExact(g,f,lv,...)
	return g:GetSum(cm.DivideValueMax(f,...))>=lv and not g:IsExists(cm.CheckGreaterExactCounterCheck,1,nil,g,f,lv,...)
end
function cm.CheckRitualMaterial(c,g,tp,lv,f,gt)
	local f=f or Card.GetRitualLevel
	return cm.CheckGroup(g,cm.CheckRitualMaterialGoal,nil,1,lv,c,tp,lv,f,gt)
end
function cm.SelectRitualMaterial(c,g,tp,lv,f,gt)
	local f=f or Card.GetRitualLevel
	return cm.SelectGroup(tp,HINTMSG_RELEASE,g,cm.CheckRitualMaterialGoal,nil,1,lv,c,tp,lv,f,gt)
end
--for anifriends sound effects
function cm.AddSummonSE(c,desc)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(function()
		Duel.Hint(HINT_SOUND,0,desc)
	end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function cm.AddAttackSE(c,desc)
	if not cm.AttackSEList then
		cm.AttackSEList={}
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCondition(function()
			return cm.AttackSEList[Duel.GetAttacker()]
		end)
		e1:SetOperation(function()
			Duel.Hint(HINT_SOUND,0,cm.AttackSEList[Duel.GetAttacker()])
		end)
		Duel.RegisterEffect(e1,0)
	end
	cm.AttackSEList[c]=desc
end
function cm.GetPZoneCount(tp,g)
	local res=0
	for i=0,1 do
		if Duel.CheckLocation(tp,LOCATION_PZONE,i) or (g and g:IsExists(function(c) return c==Duel.GetFieldCard(tp,LOCATION_PZONE,i) or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()==i*4) end,1,nil)) then res=res+1 end
	end
	return res
end
