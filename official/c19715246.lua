--サイバー・ヨルムンガンド
--Cyber Jormungandr
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	c:AddMustBeSpecialSummonedByCardEffect()
	--Special Summon this card from your hand, then take 1 "Cyber Dragon" from your Deck, and either Special Summon it or equip it to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Polymerization" from your Deck or GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CYBER_DRAGON,CARD_POLYMERIZATION}
function s.cyberdragonfilter(c,e,tp,mon_ft,st_ft)
	return c:IsCode(CARD_CYBER_DRAGON) and (s.spfilter(c,e,tp,mon_ft) or s.eqpfilter(c,tp,st_ft))
end
function s.spfilter(c,e,tp,freezone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and freezone>0
end
function s.eqpfilter(c,tp,freezone)
	return c:CheckUniqueOnField(tp) and not c:IsForbidden() and freezone>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mon_ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local st_ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return mon_ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.cyberdragonfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mon_ft-1,st_ft) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local mon_ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local st_ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local tc=Duel.SelectMatchingCard(tp,s.cyberdragonfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mon_ft,st_ft):GetFirst()
		if tc then
			local b1=s.spfilter(tc,e,tp,mon_ft)
			local b2=s.eqpfilter(tc,tp,st_ft)
			local op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,3)},
				{b2,aux.Stringid(id,4)})
			Duel.BreakEffect()
			if op==1 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif op==2 then
				if Duel.Equip(tp,tc,c) then
					--Equip limit
					local e0=Effect.CreateEffect(tc)
					e0:SetType(EFFECT_TYPE_SINGLE)
					e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e0:SetCode(EFFECT_EQUIP_LIMIT)
					e0:SetValue(function(e,cc) return cc==c end)
					e0:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e0)
				end
			end
		end
	end
	--You cannot Special Summon for the rest of this turn, except Machine monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_MACHINE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thcostfilter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsFaceup() and c:IsAbleToHandAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.thfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end