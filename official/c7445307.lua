--デュアル・アセンブルム
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
function s.mzfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-2 and #rg>1 and (ft>0 or rg:IsExists(s.mzfilter,ct,nil,tp)) end
	local g=nil
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,s.mzfilter,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,s.mzfilter,2,2,nil,tp)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.rmfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToRemove()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
