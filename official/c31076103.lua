--第一の棺
--The First Sarcophagus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Place "The Second Sarcophagus" or "The Third Sarcophagus" in your Spell/Trap Zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and e:GetHandler():GetFlagEffect(id)<2 end)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Special Summon 1 "Spirit of the Pharaoh" from your hand or Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Send them to the GY if any leave the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.tgcon)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
s.listed_names={4081094,78697395,id,25343280}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local code=0
	local c=e:GetHandler()
	if not c:HasFlagEffect(id) then
		code=4081094
	else
		code=78697395
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,code)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
	end
end
function s.confilter(c,tp)
	return c:IsFaceup() and c:IsCode(4081094,78697395) and c:IsControler(tp) and c:IsOnField()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,4081094),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,78697395),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,id,4081094,78697395),tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED)
		and #g==g:FilterCount(Card.IsAbleToGraveAsCost,nil) end
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCode(25343280) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsCode,4081094,78697395),1,nil)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,4081094,78697395),tp,LOCATION_ONFIELD,0,nil):Merge(e:GetHandler())
	Duel.SendtoGrave(g,REASON_EFFECT)
end
