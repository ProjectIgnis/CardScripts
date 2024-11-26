--ジェムナイト・ディスパージョン
--Gem-Knight Dispersion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GEM_KNIGHT,SET_GEM}
s.listed_names={1264319} --"Gem-Knight Fusion"
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)<=2
end
function s.fextrafilter(c)
	return not c:IsRace(RACE_ROCK) and c:IsSetCard(SET_GEM_KNIGHT) and c:IsMonster() and c:IsAbleToGrave()
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1264319) then
		local eg=Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.thfilter(c)
	return c:IsSetCard(SET_GEM) and c:IsMonster() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
		and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GEM_KNIGHT),extrafil=s.fextra,extratg=s.extratg}
	--Fusion Summon 1 "Gem-Knight" Fusion Monster from your Extra Deck, using monsters from your hand or field as material
	local b1=not Duel.HasFlagEffect(tp,id)
		and Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	--Add 1 "Gem-" monster from your Deck or banishment to your hand
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 "Gem-Knight" Fusion Monster from your Extra Deck, using monsters from your hand or field as material
		local params={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GEM_KNIGHT),extrafil=s.fextra}
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Add 1 "Gem-" monster from your Deck or banishment to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		--Any effect damage your opponent takes during the Main Phase this turn is halved
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(0,1)
		e1:SetCondition(function() return Duel.IsMainPhase() end)
		e1:SetValue(function(e,re,val,r,rp,rc) return (r&REASON_EFFECT>0) and val//2 or val end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end