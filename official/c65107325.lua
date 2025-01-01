--赤酢の踏切
--Sour Scheduling - Red Vinegar Vamoose
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Zones in the same column cannot be used
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetColumnGroup():IsExists(Card.IsControler,1,nil,1-tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=c:GetColumnZone(LOCATION_ONFIELD)
	for tc in c:GetColumnGroup():Iter() do
		local ctrl=tc:IsControler(tp)
		local seq=tc:GetSequence()
		zones=zones&~(ctrl and (1<<seq) or (1<<(16+seq)))
		if tc:IsInExtraMZone() then
			zones=zones&~(ctrl and (1<<(27-seq)) or (1<<(11-seq)))
		end
	end
	return zones
end