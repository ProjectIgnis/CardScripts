--聖魔の賢王エンディミオン
--Endymion, the Lord of Magistus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	c:EnableCounterPermit(COUNTER_SPELL,LOCATION_PZONE)
	--Must be Special Summoned (from your hand or Extra Deck) by banishing 1 face-up Spell you control. You can only Special Summon "Endymion, the Lord of Magistus" once per turn this way
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND|LOCATION_EXTRA)
	e0:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--Each time a Spell Card is activated, place 1 Spell Counter on this card when it resolves
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetRange(LOCATION_PZONE)
	e1a:SetOperation(aux.chainreg)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_CHAIN_SOLVED)
	e1b:SetRange(LOCATION_PZONE)
	e1b:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:HasFlagEffect(1) then
			c:AddCounter(COUNTER_SPELL,1)
		end
	end)
	c:RegisterEffect(e1b)
	--During your Main Phase: You can destroy this card, and if you do, add 1 "Magistus" or "Endymion" monster from your Deck to your hand, except a Level 7 monster. You can only use this effect of "Endymion, the Lord of Magistus" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle or card effects while equipped with an Equip Card
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCondition(function(e)
		return e:GetHandler():HasEquipCard()
	end)
	e3a:SetValue(1)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3b)
	--At the end of the Damage Step, if this card attacked: You can banish 1 face-up Spell you control, or remove 3 Spell Counters from your field; this card gains 500 ATK, also it can attack again in a row
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.atkcon)
	e4:SetCost(s.atkcost)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAGISTUS,SET_ENDYMION}
s.listed_names={id}
s.counter_place_list={COUNTER_SPELL}
function s.spellcostfilter(c)
	return c:IsSpell() and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function s.selfspconfilter(c,hand_chk,tp,endymion)
	return s.spellcostfilter(c) and ((hand_chk and Duel.GetMZoneCount(tp,c)>0)
		or Duel.GetLocationCountFromEx(tp,tp,c,endymion)>0)
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local hand_chk=c:IsLocation(LOCATION_HAND)
	return Duel.IsExistingMatchingCard(s.selfspconfilter,tp,LOCATION_ONFIELD,0,1,nil,hand_chk,tp,c)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local hand_chk=c:IsLocation(LOCATION_HAND)
	local rg=Duel.GetMatchingGroup(s.selfspconfilter,tp,LOCATION_ONFIELD,0,nil,hand_chk,tp,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if g and #g>0 then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g and #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.thfilter(c)
	return c:IsSetCard({SET_MAGISTUS,SET_ENDYMION}) and c:IsMonster() and not c:IsLevel(7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:CanChainAttack(0)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--Banish 1 face-up Spell you control
	local option_1=Duel.IsExistingMatchingCard(s.spellcostfilter,tp,LOCATION_ONFIELD,0,1,nil)
	--Remove 3 Spell Counters from your field
	local option_2=Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	if chk==0 then return option_1 or option_2 end
	local choice=nil
	if option_1 and option_2 then
		choice=Duel.SelectEffect(tp,
			{option_1,aux.Stringid(id,3)},
			{option_2,aux.Stringid(id,4)})
	else
		choice=(option_1 and 1) or (option_2 and 2)
	end
	if choice==1 then
		--Banish 1 face-up Spell you control
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.spellcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	elseif choice==2 then
		--Remove 3 Spell Counters from your field
		Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,3,REASON_COST)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card gains 500 ATK
		c:UpdateAttack(500)
		--Also it can attack again in a row
		Duel.ChainAttack()
	end
end