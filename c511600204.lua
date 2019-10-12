--クロック・リザード
--Clock Lizard
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	--fusion summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--atk down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--workaround
	if not ClockLizardSubstituteGroup then
		ClockLizardSubstituteGroup = Group.CreateGroup()
		ClockLizardSubstituteGroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.subop)
		Duel.RegisterEffect(ge1,0)
	end
	local isexist=Duel.IsExistingMatchingCard
		Duel.IsExistingMatchingCard=function(f,tp,int_s,int_o,count,ex,...)
		local arg={...}
		if arg~=nil then
			return isexist(f,tp,int_s,int_o,count,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
		else
			return isexist(f,tp,int_s,int_o,count,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup)
		end
	end
	local isexisttg=Duel.IsExistingTarget
		Duel.IsExistingTarget=function(f,tp,int_s,int_o,count,ex,...)
		local arg={...}
		if arg~=nil then
			return isexisttg(f,tp,int_s,int_o,count,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
		else
			return isexisttg(f,tp,int_s,int_o,count,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup)
		end
	end
	local getmatchg=Duel.GetMatchingGroup
		Duel.GetMatchingGroup=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		if arg~=nil then
			return getmatchg(f,tp,int_s,int_o,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
		else
			return getmatchg(f,tp,int_s,int_o,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup)
		end
	end
	local getfg=Duel.GetFieldGroup
		Duel.GetFieldGroup=function(tp,int_s,int_o)
		return getfg(tp,int_s,int_o)-ClockLizardSubstituteGroup
	end
	local getfgc=Duel.GetFieldGroupCount
		Duel.GetFieldGroupCount=function(tp,int_s,int_o)
		return #Duel.GetFieldGroup(tp,int_s,int_o)
	end
	local getmatchgc=Duel.GetMatchingGroupCount
		Duel.GetMatchingGroupCount=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return #Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,table.unpack(arg))
	end
	local getfmatch=Duel.GetFirstMatchingCard
		Duel.GetFirstMatchingCard=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return Duel.GetMatchingGroup(f,tp,int_s,int_o,ex,table.unpack(arg)):GetFirst()
	end
	local selmatchc=Duel.SelectMatchingCard
		Duel.SelectMatchingCard=function(sp,f,tp,int_s,int_o,min,max,ex, ...)
		local arg={...}
		if arg~=nil then
			return selmatchc(sp,f,tp,int_s,int_o,min,max,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
		else
			return selmatchc(sp,f,tp,int_s,int_o,min,max,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup)
		end
	end
	local gettgc=Duel.GetTargetCount
		Duel.GetTargetCount=function(f,tp,int_s,int_o,ex,...)
		local arg={...}
		return gettgc(f,tp,int_s,int_o,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
	end
	local seltg=Duel.SelectTarget
		Duel.SelectTarget=function(sp,f,tp,int_s,int_o,min,max,ex, ...)
		local arg={...}
		if arg~=nil then
			local sel=seltg(sp,f,tp,int_s,int_o,min,max,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup,table.unpack(arg))
			Duel.SetTargetCard(sel)
			return sel
		else
			local sel=seltg(sp,f,tp,int_s,int_o,min,max,ex and ClockLizardSubstituteGroup+ex or ClockLizardSubstituteGroup)
			Duel.SetTargetCard(sel)
			return sel
		end
	end
end
function s.subop(e,tp,eg,ep,ev,re,r,rp,chk)
	for p=0,1 do
		if Duel.IsExistingMatchingCard(Card.IsCode,p,0xff,0,1,nil,id)
			and Duel.GetFieldGroupCount(p,LOCATION_EXTRA,0)==0
			and not ClockLizardSubstituteGroup:IsExists(Card.IsControler,1,nil,p) then
			local sub=Duel.CreateToken(p,id)
			sub:ResetEffect(RESET_CARD,id)
			ClockLizardSubstituteGroup:AddCard(sub)
			Duel.Sendto(sub,LOCATION_EXTRA,REASON_RULE)
		end
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.tdfilter(c,e,tp,mg,mgc,mf)
	if not c:IsType(TYPE_FUSION) or not c:IsAbleToExtra()
		or not (c:CheckFusionMaterial(mg,nil)
		or c:CheckFusionMaterial(mgc,nil) and (not mf or mf(c))) then return false end
	local fc=Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)>0 and Duel.GetFirstMatchingCard(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)
		or ClockLizardSubstituteGroup:Filter(Card.IsControler,nil,tp):GetFirst()
	if Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),fc)<=0 then return false end
	local fcspcon={}
	for _,eff in ipairs({fc:GetCardEffect(EFFECT_SPSUMMON_CONDITION)}) do
		table.insert(fcspcon,eff:Clone())
		eff:Reset()
	end
	fc:AssumeProperty(ASSUME_CODE,c:GetOriginalCodeRule())
	local fceffs={}
	local e1=Effect.CreateEffect(fc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(c:GetOriginalType())
	fc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(c:GetOriginalLevel())
	fc:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(c:GetOriginalRace())
	fc:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(c:GetOriginalAttribute())
	fc:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EFFECT_SET_BASE_ATTACK)
	e5:SetValue(c:GetTextAttack())
	fc:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_SET_BASE_DEFENSE)
	e6:SetValue(c:GetTextDefense())
	fc:RegisterEffect(e6)
	table.insert(fceffs,e1)
	table.insert(fceffs,e2)
	table.insert(fceffs,e3)
	table.insert(fceffs,e4)
	table.insert(fceffs,e5)
	table.insert(fceffs,e6)
	local sum=false
	for _,eff in ipairs({c:GetCardEffect(EFFECT_SPSUMMON_CONDITION)}) do
		local eClone=eff:Clone()
		fc:RegisterEffect(eClone,true)
		table.insert(fceffs,eClone)
	end
	if fc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then sum=true end
	for _,eff in ipairs(fceffs) do
		eff:Reset()
	end
	for _,eff in ipairs(fcspcon) do
		fc:RegisterEffect(eff,true)
	end
	return sum
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
		local ce=Duel.GetChainMaterial(tp)
		local mgc=Group.CreateGroup()
		local mf=nil
		if ce~=nil then
			mgc=ce:GetTarget()(ce,e,tp)
			mf=ce:GetValue()
		end
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc,e,tp,mg,mgc,mf)
	end
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	local ce=Duel.GetChainMaterial(tp)
	local mgc=Group.CreateGroup()
	local mf=nil
	if ce~=nil then
		mgc=ce:GetTarget()(ce,e,tp)
		mf=ce:GetValue()
	end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mg,mgc,mf) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mg,mgc,mf)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	local ce=Duel.GetChainMaterial(tp)
	local mgc=Group.CreateGroup()
	local mf=nil
	if ce~=nil then
		mgc=ce:GetTarget()(ce,e,tp)
		mf=ce:GetValue()
	end
	if tc:IsRelateToEffect(e) and s.tdfilter(tc,e,tp,mg,mgc,mf) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 then
		local nf=tc:CheckFusionMaterial(mg,nil,tp) and (not f or f(tc))
		local cef=tc:CheckFusionMaterial(mgc,nil,tp) and (not mf or mf(tc))
		if tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
			and (nf or cef) then
			Duel.BreakEffect()
			if nf and (not cef or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
				tc:SetMaterial(mat1)
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mgc,nil,tp)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.filter(c,p)
	return c:IsControler(p) and c:IsFaceup() and c:IsAttackAbove(1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.filter,1,nil,1-tp)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_CYBERSE)*400
	for tc in aux.Next(eg:Filter(s.filter,nil,1-tp)) do
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
