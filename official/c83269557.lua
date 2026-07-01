--ダーク・ヴァルキリア
--Dark Valkyria
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL,LOCATION_MZONE,Gemini.EffectStatusCondition)
	--This card is treated as a Normal Monster while face-up on the field or in the GY. While this card is a Normal Monster on the field, you can Normal Summon it to have it become an Effect Monster with these effects
	Gemini.AddProcedure(c)
	--● Once, while this card is face-up on the field: You can place 1 Spell Counter on it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Gemini.EffectStatusCondition)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsCanAddCounter(COUNTER_SPELL,1) end
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_SPELL)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			c:AddCounter(COUNTER_SPELL,1)
		end
	end)
	c:RegisterEffect(e1)
	--● This card gains 300 ATK for each Spell Counter on it
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(Gemini.EffectStatusCondition)
	e2:SetValue(function(e,c)
		return c:GetCounter(COUNTER_SPELL)*300
	end)
	c:RegisterEffect(e2)
	--● You can remove 1 Spell Counter from this card, then target 1 monster on the field; destroy that target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(Gemini.EffectStatusCondition)
	e3:SetCost(Cost.RemoveCounterFromSelf(COUNTER_SPELL,1))
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) end
		if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsMonster() then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_SPELL}