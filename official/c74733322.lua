--神芸学都アルトメギア
--Artmage Academic Arcane Arts Acropolis
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During your Main Phase, you can Normal Summon 1 "Medius the Pure", in addition to your Normal Summon/Set (you can only gain this effect once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_MEDIUS_THE_PURE))
	c:RegisterEffect(e1)
	--You can discard 1 Spell/Trap, and declare 1 "Artmage" Monster Card name that is not among the monsters you control and has not been declared for "Artmage Academic Arcane Arts Acropolis" this turn; add that monster from your Deck to your hand, also you cannot Special Summon for the rest of this turn, except "Artmage" monsters, "Medius the Pure", or from the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCost(Cost.Discard(Card.IsSpellTrap))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Track names declared to activate e2
	aux.GlobalCheck(s,function()
		s.declared_names={}
		s.declared_names[0]={}
		s.declared_names[1]={}
		aux.AddValuesReset(function()
			s.declared_names={}
			s.declared_names[0]={}
			s.declared_names[1]={}
		end)
	end)
end
s.listed_names={CARD_MEDIUS_THE_PURE}
s.listed_series={SET_ARTMAGE}
function s.declfilter(c,exc1,exc2)
	return c:IsSetCard(SET_ARTMAGE) and c:IsMonster() and c:IsAbleToHand()
		and (#exc1==0 or not c:IsCode(table.unpack(exc1)))
		and (#exc2==0 or not c:IsCode(table.unpack(exc2)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local fcs=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ARTMAGE),tp,LOCATION_MZONE,0,nil):GetClass(Card.GetCode)
	local g=Duel.GetMatchingGroup(s.declfilter,tp,LOCATION_DECK,0,nil,fcs,s.declared_names[tp])
	if chk==0 then return #g>0 end
	local announce_filter=DF.IsCode(g:GetClass(Card.GetCode))
	local announced_card=Duel.AnnounceCard(tp,announce_filter)
	table.insert(s.declared_names[tp],announced_card)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	--if the opponent tries to overwrite the announced name, they don't know what cards are in the player's Deck,
	--so they should be able to announce any "Artmage" Main Deck monster that the player did not control and had not announced yet
	local opp_announce_filter=DF.IsMainDeckMonster() & DF.IsSetCard(SET_ARTMAGE) & ~DF.IsCode(fcs) & ~DF.IsCode(s.declared_names[tp])
	e:GetChainData().announce_filter=function(_,p) return p==tp and announce_filter or opp_announce_filter end
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsMonster() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,cd.announced_card)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if not Duel.HasFlagEffect(tp,id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--You cannot Special Summon for the rest of this turn, except "Artmage" monsters, "Medius the Pure", or from the Extra Deck.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return not (c:IsSetCard(SET_ARTMAGE) or c:IsCode(CARD_MEDIUS_THE_PURE) or c:IsLocation(LOCATION_EXTRA)) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
