--オルターガイスト・エミュレルフ
--Altergeist Emulatelf
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ALTERGEIST}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ALTERGEIST,TYPE_MONSTER|TYPE_EFFECT,1400,1800,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ALTERGEIST,TYPE_MONSTER|TYPE_EFFECT,1400,1800,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.etarget)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2,true)
	Duel.SpecialSummonComplete()
end
function s.etarget(e,c)
	return c:IsSetCard(SET_ALTERGEIST) and c:IsTrap() and c~=e:GetHandler()
end