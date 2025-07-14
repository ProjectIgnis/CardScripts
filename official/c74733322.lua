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
	--During your Main Phase, you can Normal Summon 1 "Medius the Pure" in addition to your Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_MEDIUS_THE_PURE))
	c:RegisterEffect(e1)
	--Add 1 declared "Artmage" monster from your Deck to your hand
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
		and (#exc1==0 or not c:IsCode(table.unpack(exc1))) and (#exc2==0 or not c:IsCode(table.unpack(exc2)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local fcs=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ARTMAGE),tp,LOCATION_MZONE,0,nil):GetClass(Card.GetCode)
	local g=Duel.GetMatchingGroup(s.declfilter,tp,LOCATION_DECK,0,nil,fcs,s.declared_names[tp])
	if chk==0 then return #g>0 end
	s.announce_filter={}
	for _,code in ipairs(g:GetClass(Card.GetCode)) do
		if #s.announce_filter==0 then
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
		else
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
			table.insert(s.announce_filter,OPCODE_OR)
		end
	end
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	table.insert(s.declared_names[tp],ac)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsMonster() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if not Duel.HasFlagEffect(tp,id) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Cannot Special Summon from outside the Extra Deck for the rest of this turn, except "Artmage" monsters and "Medius the Pure"
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