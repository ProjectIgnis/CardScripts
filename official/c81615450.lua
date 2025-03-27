--レプティレス・ラミフィケーション
--Reptilianne Ramifications
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_REPTILIANNE}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.mfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_REPTILIANNE) and c:IsAbleToHand()
end
function s.mthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.stfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_REPTILIANNE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.stthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,nil) end
	e:SetCategory(e:GetCategory()+CATEGORY_ATKCHANGE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b0=s.mthtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b1=s.stthtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.atktg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b0 and (b1 or b2) or (b1 and b2) end
	local sel=0
	for ct=1,2 do
		local stable={}
		local dtable={}
		if b0 and (sel&0x1==0) then
			table.insert(stable,0x1)
			table.insert(dtable,aux.Stringid(id,0))
		end
		if b1 and (sel&0x2==0) then
			table.insert(stable,0x2)
			table.insert(dtable,aux.Stringid(id,1))
		end
		if b2 and (sel&0x4==0) then
			table.insert(stable,0x4)
			table.insert(dtable,aux.Stringid(id,2))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,table.unpack(dtable))+1
		sel=sel+stable[op]
	end
	if (sel&0x1==0x1) then s.mthtg(e,tp,eg,ep,ev,re,r,rp,1) end
	if (sel&0x2==0x2) then s.stthtg(e,tp,eg,ep,ev,re,r,rp,1) end
	if (sel&0x4==0x4) then s.atktg(e,tp,eg,ep,ev,re,r,rp,1) end
	e:SetLabel(sel)
end
function s.mthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.mfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.stthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectMatchingCard(tp,Card.HasNonZeroAttack,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		--ATK becomes 0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	local ct=0
	if (sel&0x1==0x1) then
		s.mthop(e,tp,eg,ep,ev,re,r,rp)
		Duel.BreakEffect()
		ct=ct+1
	end
	if (sel&0x2==0x2) then
		s.stthop(e,tp,eg,ep,ev,re,r,rp)
		if ct==0 then Duel.BreakEffect() end
	end
	if (sel&0x4==0x4) then s.atkop(e,tp,eg,ep,ev,re,r,rp) end
end