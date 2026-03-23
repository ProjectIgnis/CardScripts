--パーフェクトロン・ハイドライブ・ドラゴン
--Perfectron Hydradrive Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 1+ Link Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),1)
	--If this card is Link Summoned, or at the end of the Damage Step if this card battled: Destroy as many monsters your opponent controls as possible, then inflict 300 damage to your opponent for each Link Monster in your GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1a:SetTarget(s.destg)
	e1a:SetOperation(s.desop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_DAMAGE_STEP_END)
	c:RegisterEffect(e1b)
	--While face-up on the field, this card is also LIGHT, WATER, FIRE, and WIND-Attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_LIGHT|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND)
	c:RegisterEffect(e2)
	--Unaffected by the activated effects of monsters that share an Attribute with this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--If this card with 1000 or more ATK would be destroyed by battle or card effect, you can make its ATK become reduced by 1000 instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.desreptg)
	c:RegisterEffect(e4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local dam=300*Duel.GetMatchingGroupCount(Card.IsLinkMonster,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local dam=300*Duel.GetMatchingGroupCount(Card.IsLinkMonster,tp,LOCATION_GRAVE,0,nil)
		if dam>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
function s.immval(e,te)
	local trig_loc,trig_attr=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTRIBUTE)
	if not (te:IsMonsterEffect() and te:IsActivated()) then return false end
	local c=e:GetHandler()
	local tc=te:GetHandler()
	if not Duel.IsChainSolving() or (tc:IsRelateToEffect(te) and tc:IsFaceup() and tc:IsLocation(trig_loc)) then
		return c:IsAttribute(tc:GetAttribute())
	else
		return c:GetAttribute()&trig_attr>0
	end
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(1000) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		--Make its ATK become reduced by 1000 instead
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()-1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		return true
	end
	return false
end