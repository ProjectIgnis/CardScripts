--トポロジック・ブラスター・ドラゴン
--Topologic Blaster Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--You cannot Summon/Set monsters to any Extra Monster Zone this card points to
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_FORCE_MZONE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,0)
	e0:SetValue(function(e) return ~(e:GetHandler():GetLinkedZone()&ZONES_EMZ) end)
	c:RegisterEffect(e0)
	--Apply 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EMZONE)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_name={id}
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	local linkg=Duel.GetMatchingGroup(Card.IsLinkMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for lc in linkg:Iter() do
		if aux.zptgroupcon(eg,nil,lc) then return true end
	end
	return false
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	--Shuffle all other monsters on the field into the Deck
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
	--Shuffle all Spells and Traps on the field into the Deck
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	--Look at your opponent's Extra Deck and banish 1 card from it
	local b3=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
	if chk==0 then return (b1 or b2 or b3) end
	if not Duel.HasFlagEffect(tp,id) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	end
	if not Duel.HasFlagEffect(tp,id+1) then
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
	end
	if not Duel.HasFlagEffect(tp,id+2) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,tp)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,exc)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==1 then
		--Shuffle all other monsters on the field into the Deck
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif op==2 then
		--Shuffle all Spells and Traps on the field into the Deck
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif op==3 then
		--Look at your opponent's Extra Deck and banish 1 card from it
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		if #sg>0 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
		Duel.ShuffleExtra(1-tp)
	end
end