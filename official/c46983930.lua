--レイズ・ムーンの星々
--The Stars of Raise Moon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Raise Moon" card from your Deck on top of your Deck, except "The Stars of Raise Moon", but you cannot place another card with the same name with this effect of "The Stars of Raise Moon" this turn, also neither player can add cards from the Deck to the hand for the rest of this turn after this card resolves, except by drawing them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then activate 1 of these effects;
	--● Each player draws 1 card
	--● If you control a Spellcaster "Raise Moon" Xyz Monster: Draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--Keep track of the chosen cards' names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
end
s.listed_series={SET_RAISE_MOON}
s.listed_names={id}
function s.plfilter(c,tp)
	return c:IsSetCard(SET_RAISE_MOON) and not c:IsCode(id) and not s.name_list[tp][c:GetCode()]
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if sc then
			Duel.ShuffleDeck(tp)
			Duel.MoveToDeckTop(sc)
			Duel.ConfirmDecktop(tp,1)
			--You cannot place another card with the same name with this effect of "The Stars of Raise Moon" this turn
			s.name_list[tp][sc:GetCode()]=true
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Also neither player can add cards from the Deck to the hand for the rest of this turn after this card resolves, except by drawing them
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(1,1)
	e1:SetTarget(function(e,c,tp,re)
		return c:IsLocation(LOCATION_DECK)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.drconfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(SET_RAISE_MOON) and c:IsXyzMonster() and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local option_1=Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1)
	local option_2=Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.drconfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,4)},
		{option_2,aux.Stringid(id,5)})
	e:GetChainData().choice=choice
	local player=choice==1 and PLAYER_ALL or tp
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,player,1)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Each player draws 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.Draw(1-tp,1,REASON_EFFECT)
	elseif choice==2 then
		--● If you control a Spellcaster "Raise Moon" Xyz Monster: Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end