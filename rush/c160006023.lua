-- SPシャイン・ガード Shining SP Corporate Guard
--Secret Service Shine Guard
local s,id=GetID()
function s.initial_effect(c)
	-- Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160006046,160006047}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #sg>0 end
end
function s.sfilter(c)
	return c:IsCode(160006046,160006047) and c:IsSSetable()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,160006046)<2 and sg:FilterCount(Card.IsCode,nil,160006047)<2
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	Duel.PayLPCost(tp,600)
	-- Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- Set cards
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
		if ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,s.rescon,1,tp)
			Duel.HintSelection(tg)
			Duel.SSet(tp,tg)
		end
		--Prevent non-machine from attacking
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_MACHINE)
end