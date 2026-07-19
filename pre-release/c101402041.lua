--魔救の奇跡－ティアマイト
--Adamancipator Risen - Tiamite
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If you have a DARK monster in your GY: You can add 1 "Adamancipator" Spell/Trap from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp)
		return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
	end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--When your opponent activates a monster effect on the field (Quick Effect): You can excavate the top 5 cards of your Deck, and if you do, you can return cards your opponent controls to the hand, up to the number of excavated Rock monsters, also place the excavated cards on the bottom of the Deck in any order
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp and Chain.IsTriggeringLocation(ev,LOCATION_MZONE)
	end)
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ADAMANCIPATOR}
function s.thfilter(c,e,tp)
	return c:IsSetCard(SET_ADAMANCIPATOR) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	local excavg=Duel.GetDecktopGroup(tp,5)
	local excav_count=#excavg
	local excav_rock_count=excavg:FilterCount(Card.IsRace,nil,RACE_ROCK)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if excav_rock_count>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local return_count=math.min(#g,excav_rock_count)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local sg=g:Select(tp,1,return_count,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			local og=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_HAND)
			if #og>0 then
				if og:IsExists(Card.IsControler,1,nil,tp) then
					Duel.ShuffleHand(tp)
				end
				if og:IsExists(Card.IsControler,1,nil,1-tp) then
					Duel.ShuffleHand(1-tp)
				end
			end
		end
	end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>excav_count then
		Duel.MoveToDeckBottom(excav_count,tp)
	end
	Duel.SortDeckbottom(tp,tp,excav_count)
end