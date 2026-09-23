--燦冠乗騎シックラヴィー
--Swickelavee the Brilliantly Crowned Heavy Cavalry
--scripted by Naim
local s,id=GetID()
local COUNTER_CROWN=0x21c
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_CROWN)
	--Xyz Summon procedure: 2 Level 3 monsters, OR, once per turn, you can also Xyz Summon "Swickelavee the Brilliantly Crowned Heavy Cavalry" by using 1 Beast monster you control with 2000 or less ATK
	Xyz.AddProcedure(c,nil,3,2,s.altxyzmat,aux.Stringid(id,0),2,s.altxyzop)
	--Cannot be used as material for an Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--If this card destroys a monster by battle: Place 1 Crown Counter on it, then apply this effect based on the number of Crown Counters on it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_ATKCHANGE+CATEGORY_TOEXTRA+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(function(e)
		return e:GetHandler():IsRelateToBattle()
	end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.counter_place_list={COUNTER_CROWN}
function s.altxyzmat(c,tp,xyz)
	return c:IsRace(RACE_BEAST,xyz,SUMMON_TYPE_XYZ,tp) and c:IsAttackBelow(2000) and c:IsFaceup()
end
function s.altxyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local crown_counters=c:GetCounter(COUNTER_CROWN)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_CROWN)
	if crown_counters<3 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,crown_counters==1 and 400 or 600)
	end
	if crown_counters==2 then
		Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,3)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:AddCounter(COUNTER_CROWN,1) then
		local crown_counters=c:GetCounter(COUNTER_CROWN)
		if crown_counters==1 then
			--● 1: This card gains 400 ATK
			c:UpdateAttack(400)
		elseif crown_counters==2 then
			--● 2: This card gains 600 ATK
			c:UpdateAttack(600)
		elseif crown_counters==3 then
			--● 3: Return this card to the Extra Deck, and if you do, draw 3 cards
			if Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsLocation(LOCATION_EXTRA) then
				Duel.Draw(tp,3,REASON_EFFECT)
			end
		end
	end
end