--稲妻の戦士－ギルフォード・ザ・ライトニング
--Gilford the Lightning, the Warrior of Thunderbolts
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by Tributing 3 monsters, and if you Tributed a monster(s) that is owned by your opponent, your opponent cannot activate cards or effects when this card is Special Summoned this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If Summoned this way: Your opponent must send all monsters they control to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_RULE,PLAYER_NONE,1-tp)
		end
	end)
	c:RegisterEffect(e2)
	--If this card is sent to the GY: You can activate this effect; during the End Phase of this turn, add 1 Warrior monster from your Deck to your hand. You can only use this effect of "Gilford the Lightning, the Warrior of Thunderbolts" once per turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.regtg)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,nil,3,false,3,true,c,tp,nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,nil,3,3,false,true,true,c,tp,nil,false,nil)
	if g then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g and Duel.Release(g,REASON_COST)>0 and g:IsExists(Card.IsOwner,1,nil,1-tp) then
		--If you Tributed a monster(s) that is owned by your opponent, your opponent cannot activate cards or effects when this card is Special Summoned this way
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.SetChainLimitTillChainEnd(function(e,ep,tp)
				return tp==ep
			end)
		end)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD))
		c:RegisterEffect(e1)
	end
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
	--During the End Phase of this turn, add 1 Warrior monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end