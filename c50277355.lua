--クロシープ
--Clotheep
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(aux.zptcon(nil))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetCode)==#g
end
s.ritfilter=aux.FilterFaceupFunction(Card.IsRitualMonster)
function s.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroup():IsExists(s.ritfilter,1,nil) and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
s.fusfilter=aux.FilterFaceupFunction(Card.IsType,TYPE_FUSION)
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroup():IsExists(s.fusfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
s.synfilter=aux.FilterFaceupFunction(Card.IsType,TYPE_SYNCHRO)
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroup():IsExists(s.synfilter,1,nil) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
s.xyzfilter=aux.FilterFaceupFunction(Card.IsType,TYPE_XYZ)
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLinkedGroup():IsExists(s.xyzfilter,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.rittg(e,tp,eg,ep,ev,re,r,rp,0) or s.fustg(e,tp,eg,ep,ev,re,r,rp,0)
		or s.syntg(e,tp,eg,ep,ev,re,r,rp,0) or s.xyztg(e,tp,eg,ep,ev,re,r,rp,0) end
	if s.rittg(e,tp,eg,ep,ev,re,r,rp,0) then 
		s.rittg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	if s.fustg(e,tp,eg,ep,ev,re,r,rp,0) then 
		s.fustg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	if s.syntg(e,tp,eg,ep,ev,re,r,rp,0) then 
		s.syntg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	if s.xyztg(e,tp,eg,ep,ev,re,r,rp,0) then 
		s.xyztg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.ritop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		tc:UpdateAttack(700,nil,c)
	end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:UpdateAttack(-700,nil,c)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if s.rittg(e,tp,eg,ep,ev,re,r,rp,0) then 
		s.ritop(e,tp,eg,ep,ev,re,r,rp)
	end
	if s.fustg(e,tp,eg,ep,ev,re,r,rp,0) then 
		Duel.BreakEffect()
		s.fusop(e,tp,eg,ep,ev,re,r,rp)
	end
	if s.syntg(e,tp,eg,ep,ev,re,r,rp,0) then 
		Duel.BreakEffect()
		s.synop(e,tp,eg,ep,ev,re,r,rp)
	end
	if s.xyztg(e,tp,eg,ep,ev,re,r,rp,0) then 
		Duel.BreakEffect()
		s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	end
end

