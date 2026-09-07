--貪食魚グリーディス
--Gluttonous Reptolphin Greethys
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can target 1 Fish, Sea Serpent, or Aqua monster in your GY with an equal or lower Level than the number of cards in your opponent's hand; Special Summon it, but it cannot activate its effects this turn. You can only use this effect of "Gluttonous Reptolphin Greethys" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY as Synchro Material: You can make the Synchro Monster that used this card as material gain 200 ATK/DEF for each card currently in your opponent's hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.atkdefchcon)
	e2:SetOperation(s.atkdefchop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp,lv)
	return c:IsMonster() and c:IsRace(RACE_AQUA|RACE_FISH|RACE_SEASERPENT)
		and c:HasLevel() and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sum=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,sum) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sum>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,sum) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,sum)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot activate its effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.atkdefchcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end
function s.atkdefchop(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)*200
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	if sync and sync:IsFaceup() then
		--Gains 200 ATK/DEF for each card currently in your opponent's hand
		sync:UpdateAttack(val,RESET_EVENT|RESETS_STANDARD,c)
		sync:UpdateDefense(val,RESET_EVENT|RESETS_STANDARD,c)
	end
end
