--六花水月
--Rikka June Moon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--When you activate this card, you can also Tribute 1 Plant monster; take 2 "Rikka" monsters from your Deck with the same Level, but different names, add 1 of them to your hand and send the other to the GY, also if you Tributed a monster at activation, your opponent cannot target "Rikka" monsters you control with card effects this turn. For the rest of this turn after this card resolves, you cannot Special Summon from the Extra Deck, except Plant Xyz Monsters. You can only activate 1 "Rikka June Moon" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.thtgcost)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RIKKA}
function s.thtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.CheckReleaseGroupCost(tp,Card.IsRikkaReleasable,1,false,nil,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectReleaseGroupCost(tp,Card.IsRikkaReleasable,1,1,false,nil,nil,tp)
		Duel.Release(g,REASON_COST)
		e:GetChainData().tributed_monster=true
	end
end
function s.thtgfilter(c)
	return c:IsSetCard(SET_RIKKA) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtgrescon(sg)
	local a,b=sg:GetFirst(),sg:GetNext()
	return a and b and a:IsLevel(b:GetLevel()) and not a:IsCode(b:GetCode())
		and ((a:IsAbleToHand() and b:IsAbleToGrave()) or (a:IsAbleToGrave() and b:IsAbleToHand()))
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thtgfilter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.thtgrescon,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thtgfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.thtgrescon,1,tp,aux.Stringid(id,2))
	if #sg==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		if #hg>0 then
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
			Duel.SendtoGrave(sg-hg,REASON_EFFECT)
		end
	end
	local c=e:GetHandler()
	if e:GetChainData().tributed_monster then
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
		--If you Tributed a monster at activation, your opponent cannot target "Rikka" monsters you control with card effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RIKKA))
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		--For the rest of this turn after this card resolves, you cannot Special Summon from the Extra Deck, except Plant Xyz Monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c)
			return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_PLANT) and c:IsXyzMonster())
		end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--"Clock Lizard" check
		aux.addTempLizardCheck(c,tp,function(e,c) return not (c:IsXyzMonster() and c:IsOriginalRace(RACE_PLANT)) end)
	end
end