--Ｅ・ＨＥＲＯ クレイ・ガードマン
--Elemental HERO Clay Guardian
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(84327329)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		--Metamorphosis
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetCondition(s.con)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={84327329}
function s.filter(c)
	return c:GetOriginalCode()==46411259
end
function s.con(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,0xff,0xff,1,nil)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0xff,0xff,nil)
	g:ForEach(function(c)
		local acte=c:GetActivateEffect()
		acte:SetTarget(s.target)
		acte:SetOperation(s.activate)
	end)
end
function s.filter1(c,e,tp)
	local lv=c:GetLevel()
	return lv>0 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,lv,e,tp,c)
		and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function s.filter2(c,lv,e,tp,tc)
	return c:IsType(TYPE_FUSION) and c:GetLevel()==lv
		and c:IsCanBeSpecialSummoned(e,0,tp,tc:IsCode(84327329) and c:GetOriginalCode()==id,false)
end
function s.filter3(c,lv,e,tp,tc)
	return c:IsType(TYPE_FUSION) and c:GetLevel()==lv
		and c:IsCanBeSpecialSummoned(e,0,tp,tc:GetPreviousCodeOnField()==84327329 and c:GetOriginalCode()==id,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,s.filter1,1,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroup(tp,s.filter1,1,1,nil,e,tp)
	e:SetLabelObject(rg:GetFirst())
	e:SetLabel(rg:GetFirst():GetLevel())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel(),e,tp,tc):GetFirst()
	local clayGuardianChk=tc:GetPreviousCodeOnField()==84327329 and sc:IsOriginalCode(id)
	if sc and Duel.SpecialSummon(sc,0,tp,tp,clayGuardianChk,false,POS_FACEUP)>0 and clayGuardianChk then
		sc:CompleteProcedure()
	end
end
---------------------------------------------------------------------
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
