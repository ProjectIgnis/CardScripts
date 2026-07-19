--完全なる世界 トゥーン・ワールド
--Toon World the Perfect World
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--This card's name becomes "Toon World" while in the Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(CARD_TOON_WORLD)
	c:RegisterEffect(e1)
	--Once per turn: You can add 1 "Toon" card, or 1 card that mentions a "Toon" card's name, from your Deck to your hand. You can only use this effect of "Toon World the Perfect World" thrice per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(3,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Before resolving another activated card or effect, you can banish 1 Toon monster you control until immediately after that card/effect resolves, also you cannot banish monsters with that same original name with this effect of "Toon World the Perfect World" for the rest of this turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Keep track of already banished cards
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
s.listed_names={CARD_TOON_WORLD}
s.listed_series={SET_TOON}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end
function s.thfilter(c)
	return (c:IsSetCard(SET_TOON) or c:ListsCodeWithArchetype(SET_TOON)) and c:IsAbleToHand()
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
function s.rmfilter(c,tp)
	return c:IsType(TYPE_TOON) and c:IsFaceup() and c:IsAbleToRemove() and not s.name_list[tp][c:GetOriginalCodeRule()]
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActivated() and re:GetHandler()~=e:GetHandler()
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil,tp)
	if #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc then
			Duel.HintSelection(sc)
			--Banish 1 Toon monster you control until immediately after that card/effect resolves
			local temp_banish_eff=aux.RemoveUntil(sc,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,nil,RESET_CHAIN)
			local e1=temp_banish_eff:Clone()
			e1:SetCode(EVENT_CHAIN_SOLVED)
			Duel.RegisterEffect(e1,tp)
			temp_banish_eff:Reset()
			--Also you cannot banish monsters with that same original name with this effect of "Toon World the Perfect World" for the rest of this turn
			s.name_list[tp][sc:GetOriginalCodeRule()]=true
		end
	end
end