--暗黒の太陽神－ラーの翼神竜
--The Sun God of Darkness - The Winged Dragon of Ra
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "The Winged Dragon of Ra" + 3 "Sun God" monsters
	Fusion.AddProcMixN(c,true,true,CARD_RA,1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SUN_GOD),3)
	--Unaffected by other cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te)
		return te:GetOwner()~=e:GetOwner()
	end)
	c:RegisterEffect(e1)
	--Once per turn, during the Main Phase (Quick Effect): You can discard any number of "Sun God" cards, then choose that many of your opponent's occupied Main Monster Zones; your opponent must send the monsters in those zones to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e2:SetCost(
		Cost.Discard(function(c)
			return c:IsSetCard(SET_SUN_GOD)
		end,nil,1,
		function(e,tp)
			return Duel.GetFieldGroupCount(tp,0,LOCATION_MMZONE)
		end)
	)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--When an attack is declared involving this card: You can pay LP so that you only have 1 left; this card gains ATK/DEF equal to the amount of LP paid and the total ATK of all "Sun God" monsters currently in your GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsRelateToBattle()
	end)
	e3:SetCost(Cost.PayLP(1,true))
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			local cost_lp_paid=e:GetChainData().cost_lp_paid
			local total_gy_atk=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_SUN_GOD):GetSum(Card.GetAttack)
			local val=cost_lp_paid+total_gy_atk
			--This card gains ATK/DEF equal to the amount of LP paid and the total ATK of all "Sun God" monsters currently in your GY
			c:UpdateAttack(val)
			c:UpdateDefense(val)
		end
	end)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_RA}
s.listed_series={SET_SUN_GOD}
s.material_setcode={SET_THE_WINGED_DRAGON_OF_RA,SET_SUN_GOD}
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MMZONE)
	local filter=0
	for mc in mg:Iter() do
		filter=filter|(1<<(mc:GetSequence()+16))
	end
	local cd=e:GetChainData()
	local cost_discarded_cards_count=#cd.cost_discarded_cards
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local chosen_zones=Duel.SelectFieldZone(tp,cost_discarded_cards_count,0,LOCATION_MZONE,~filter)
	Duel.Hint(HINT_ZONE,tp,chosen_zones)
	cd.chosen_zones=chosen_zones
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local chosen_zones=e:GetChainData().chosen_zones
	local g=Duel.GetMatchingGroup(aux.IsZone,tp,0,LOCATION_MMZONE,nil,chosen_zones,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_RULE,nil,1-tp)
	end
end