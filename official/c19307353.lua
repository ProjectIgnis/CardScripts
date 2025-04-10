--魂の造形家
--Spirit Sculptor
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.statsum(c)
	return math.max(c:GetTextAttack(),0)+math.max(c:GetTextDefense(),0)
end
function s.cfilter(c,tp)
	if not (c:IsAttackAbove(0) and c:IsDefenseAbove(0)) then return false end
	if not (c:GetTextAttack()>=0 and c:GetTextDefense()>=0) then return false end
	local total=s.statsum(c)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,total)
end
function s.thfilter(c,total)
	if not (c:GetTextAttack()>=0 and c:GetTextDefense()>=0) then return false end
	local ctotal=s.statsum(c)
	return c:IsMonster() and c:IsAbleToHand() and ctotal==total
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp):GetFirst()
	local total=s.statsum(tc)
	e:SetLabel(total)
	Duel.Release(tc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local total=e:GetLabel()
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,total)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end