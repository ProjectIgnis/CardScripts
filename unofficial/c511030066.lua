--ダークワイト＠イグニスター
--Darkwight @Ignister
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon proc added manually to implement its EMZ condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.emzcon)
	e0:SetTarget(Link.Target(s.matfilter,1,1,nil))
	e0:SetOperation(Link.Operation(s.matfilter,1,1,nil))
	e0:SetValue(s.linksumval)
	c:RegisterEffect(e0)
	c:EnableReviveLimit()
	--Cannot be attack target while linked
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--Damage LP
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		--overwriting functions to handle effects that Special Summon while treating it as a Link Summon
		local iscan=Card.IsCanBeSpecialSummoned
		Card.IsCanBeSpecialSummoned=function(c,e,sumtype,tp,con,limit,sump,sumptp,zone,...)
			if not sump then sump=POS_FACEUP end
			if not sumptp then sumptp=tp end
			if not zone then zone=0xff end
			if c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
				zone=zone&0x60
			end
			return iscan(c,e,sumtype,tp,con,limit,sump,sumptp,zone,...)
		end
		local spstep = Duel.SpecialSummonStep
		Duel.SpecialSummonStep = function(c,sumtype,tp,sumtp,con,check,sump,zone,...)
			if not zone then zone=0xff end
			if c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK then
				zone=zone&0x60
			end
			return spstep(c,sumtype,tp,sumtp,con,check,sump,zone,...)
		end
	end
end
s.listed_names={}
s.matfilter=aux.FilterBoolFunctionEx(Card.IsType,TYPE_NORMAL)
function s.emzcon(e,c)
	local tp=e:GetHandler():GetControler()
	local g=Duel.GetMatchingGroup(Card.IsInExtraMZone,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==2 then
		return false
	elseif #g==1 and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false,POS_FACEUP,tp,0x60) then
		return s.linkcon(e,e:GetHandler())
	elseif #g==0 then
		return s.linkcon(e,e:GetHandler())
	end
end
function s.linkcon(e,c)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local mg=g:Filter(Link.ConditionFilter,nil,s.matfilter,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
	if mustg:IsExists(aux.NOT(Link.ConditionFilter),1,nil,s.matfilter,c,tp) then return false end
	local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
	local sg=mustg
	return (mg+tg):Includes(mustg) and ((#sg>=1 and Link.CheckGoal(tp,mustg,c,1,s.matfilter,nil,{})) or (mg+tg):IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,1,1,s.matfilter,nil,mg,emt))
end
function s.linksumval(e,c)
	return SUMMON_TYPE_LINK,0x60
end
function s.tgcon(e)
	return e:GetHandler():IsLinked()
end
function s.cfil(c,tp)
	return c:GetPreviousControler()==tp
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfil,1,nil,1-tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
