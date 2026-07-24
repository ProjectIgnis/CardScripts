--不死のデスロード
--Invincible Demise Lord
--scripted by pyrQ
local s,id=GetID()
local CARD_SLASH_DRAW=71344451
function s.initial_effect(c)
	--During the End Phase, if a monster(s) was destroyed by battle this turn: You can Special Summon this card from your hand or GY, and if "Invincible Demise Lord" was destroyed by battle this turn, this card's original ATK becomes 3000, also it cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function() return Duel.HasFlagEffect(0,id) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--During your Main Phase: You can reveal cards in your Deck, including "Slash Draw", equal to the number of cards your opponent controls +1 and place those revealed cards on top of the Deck in any order
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--Keep track of monsters destroyed by battle
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
				if eg:IsExists(Card.IsPreviousCodeOnField,1,nil,id) then
					Duel.RegisterFlagEffect(1,id,RESET_PHASE|PHASE_END,0,1)
				end
			end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={id,CARD_SLASH_DRAW}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		and Duel.HasFlagEffect(1,id) then
		--If "Invincible Demise Lord" was destroyed by battle this turn, this card's original ATK becomes 3000, also it cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3001)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
		return deck_count>1 and deck_count>=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+1
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_SLASH_DRAW)
	end
end
function s.rescon(sg,e,tp,mg)
	local res=sg:IsExists(Card.IsCode,1,nil,CARD_SLASH_DRAW)
	return res,not res
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_SLASH_DRAW) then return end
	local reveal_count=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+1
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if #g<reveal_count then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,reveal_count,reveal_count,s.rescon,1,tp,HINTMSG_CONFIRM)
	if #sg==reveal_count then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(sg)
		if reveal_count>1 then Duel.SortDecktop(tp,tp,reveal_count) end
	end
end