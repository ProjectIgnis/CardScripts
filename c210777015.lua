--Red-Eyes Lightining Dragon
--designed by DavidKManner#3522, scripted by Naim
function c210777015.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c210777015.splimit)
	c:RegisterEffect(e2)
	--reveal ssummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777015,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c210777015.target)
	e3:SetOperation(c210777015.operation)
	c:RegisterEffect(e3)	
end
function c210777015.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x3b) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c210777015.rvfilter(c)
	return c:IsSetCard(0x3b)
end
function c210777015.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210777015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function c210777015.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.DisableShuffleCheck()
	local g1=Duel.GetDecktopGroup(tp,3)
	Duel.ConfirmDecktop(tp,3)
	Duel.SortDecktop(tp,tp,3)
	if g1:IsExists(c210777015.rvfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
	Duel.IsExistingMatchingCard(c210777015.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(210777015,1)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210777015.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g2:GetCount()>0 then
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
	end
end
