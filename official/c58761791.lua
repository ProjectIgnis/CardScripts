--誤出荷
--Shipment Error
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--An activated effect becomes "Your opponent takes 1 card from their Deck for you to add to your hand, and you must keep that card revealed"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.changecon)
	e1:SetTarget(s.changetg)
	e1:SetOperation(s.changeop)
	c:RegisterEffect(e1)
end
function s.changecon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasCategory(CATEGORY_SEARCH) or re:IsHasCategory(CATEGORY_DRAW) then return true end
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_TOHAND)
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_DECK)>0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
end
function s.changetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,1-rp,LOCATION_DECK,0,1,nil) end
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.replaceop)
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	Duel.Hint(HINT_SELECTMSG,opp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(opp,Card.IsAbleToHand,opp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,tp,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		--Keep it revealed
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		--During the End Phase of this turn, shuffle it into the Deck, and if you do, draw 1 card
		aux.DelayedOperation(sc,PHASE_END,id,e,tp,
			function()
				if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK) then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		)
	end
end