--冷薔薇の抱香
--Frozen Roars
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate (draw and discard)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.check=false
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	s.check=true
	if chk==0 then return true end
end
function s.cfilter(c,chk,p,chk1,chk2)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and ((chk == 0 and c:IsRace(RACE_PLANT)==p)
		or ((c:IsRace(RACE_PLANT) and chk1) or (not c:IsRace(RACE_PLANT) and chk2)))
end
function s.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk1 = Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,0,true)
	local chk2 = Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,0,false)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then
		if not s.check then return false end
		s.check=false
		return chk1 or chk2
	end
	e:SetLabel(0)
	e:SetCategory(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,1,nil,chk1,chk2)
	local opt=g:GetFirst():IsRace(RACE_PLANT) and 0 or 1
	Duel.SendtoGrave(g,REASON_COST)
	if opt == 0 then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_DECK)
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,PLAYER_ALL,id)
	if Duel.Draw(tp,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(s.drop)
		Duel.RegisterEffect(e1,tp)
	elseif opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

