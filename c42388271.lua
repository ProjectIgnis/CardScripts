--星遺物－『星櫃』
--World Legacy - "World Ark"
--scripted by Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon link monster, optional trigger effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Treated as double tributes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Send 1 monster from your deck to GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.dkcon)
	e3:SetTarget(s.dktg)
	e3:SetOperation(s.dkop)
	c:RegisterEffect(e3)
end
	--Check for link monster that was destroyed due to opponent's card effect
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) 
		and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField() & TYPE_LINK ~= 0
		and c:IsReason(REASON_DESTROY) and ((c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
	--Check if ever happened
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
	--Cost of sending from hand to GY
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
	--Check for link monsters that can be special summoned
function s.spfilter(c,e,tp)
	return c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsCanBeEffectTarget(e)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return eg:IsContains(chkc) and s.spfilter(chkc,e,tp) end 
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(s.spfilter,1,nil,e,tp) end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON) 
	local g=eg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp) 
	Duel.SetTargetCard(g) 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0) 
end
	--Performing the effect of special summoning
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
	--If opponent special summons from extra deck
function s.edfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
	--If this ever happened and monster was normal summoned
function s.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.edfilter,1,nil,1-tp) and e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) and rp~=tp
end
	--Check for a monster
function s.dkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
	--Activation legality
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dkfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
	--Performing the effect of sending a monster from deck to GY
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.dkfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

