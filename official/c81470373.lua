--ＢＦ－毒風のシムーン
--Blackwing - Simoon the Poison Wind
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Black Whirlwind" from your Deck face-up in your Spell & Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 end)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BLACKWING}
s.listed_names={91351370} --Black Whirlwind
function s.cfilter(c)
	return c:IsSetCard(SET_BLACKWING) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.plfilter(c,tp)
	return c:IsCode(91351370) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		--Can be Normal Summoned without Tributes
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(s.ntcon)
		c:RegisterEffect(e1)
		local summonable=c:IsSummonable(true,e1)
		e1:Reset()
		return (summonable or c:IsAbleToGrave()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except DARK monsters
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(function(_e,_c) return _c:IsLocation(LOCATION_EXTRA) and not _c:IsAttribute(ATTRIBUTE_DARK) end)
	e0:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_e,_c) return not _c:IsOriginalAttribute(ATTRIBUTE_DARK) end)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		--Send it to the GY during the End Phase and take 1000 damage
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,s.gyop,nil,0,0,aux.Stringid(id,2))
		if not c:IsRelateToEffect(e) then return end
		--Can be Normal Summoned without Tributes
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(s.ntcon)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		local b1=c:IsAbleToGrave()
		local b2=c:IsSummonable(true,e1)
		if not (b1 or b2) then
			e1:Reset()
			return
		end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
		Duel.BreakEffect()
		if op==1 then
			Duel.SendtoGrave(c,REASON_EFFECT)
		else
			Duel.Summon(tp,c,true,e1)
		end
	end
end
function s.gyop(ag,e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(ag,REASON_EFFECT)
	Duel.Damage(tp,1000,REASON_EFFECT)
end