--精霊コロゾ
--Magistus Chorozo
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustFirstBeFusionSummoned()
	--Fusion Materials: 1 Fusion, Synchro, Xyz, or Link Monster + 1 Spellcaster monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK),aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
	Fusion.AddContactProc(c,function(tp) return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil) end,function(g) Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL) end,nil,nil,nil,nil,false)
	--Negate an attack and make this card gain ATK equal to the attacking monster's until the end of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.miracle_synchro_fusion=true
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ac=Duel.GetAttacker()
	if chkc then return chkc==ac end
	if chk==0 then return ac:IsOnField() and ac:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(ac)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,ac,1,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.NegateAttack() and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		if atk<=0 then return end
		local prev_atk=c:GetAttack()
		--This card gains ATK equal to that monster's until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
		Duel.AdjustInstantly(c)
		if prev_atk>=c:GetAttack() then return end
		if tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end