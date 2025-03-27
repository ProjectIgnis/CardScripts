--Ｈ・Ｃ ナックル・ナイフ
--Heroic Challenger - Knuckle Sword
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If Normal or Special Summoned, change levels
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
	--Lists "Heroic" archetype
s.listed_series={SET_HEROIC}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_HEROIC) and not c:IsLevel(1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
	--Special Summon itself from hand
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
	--Check for another Warrior monster with a different level
function s.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
	--Activation legality
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,lv) end
	if chk==0 then return lv>0 and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c,lv)
end
	--Change levels
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsLevel(c:GetLevel()) then
		local g=Group.FromCards(c,tc)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) --Select the monster with the level you want
		local sg=g:Select(tp,1,1,nil)
		local oc=(g-sg):GetFirst()
		--Change Level
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(sg:GetFirst():GetLevel())
		oc:RegisterEffect(e1)
	end
	--Cannot declare attacks, except with Xyz Monsters
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	ge1:SetTargetRange(LOCATION_MZONE,0)
	ge1:SetTarget(function(e,c) return not c:IsType(TYPE_XYZ) end)
	ge1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3),nil)
end