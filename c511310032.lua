--リンク・ラッシュ
--Link Rush
--Scripted by AlphaKretin
--fixed by Larry126
local card, code = GetID()
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(card.descon)
	e1:SetTarget(card.destg)
	e1:SetOperation(card.desop)
	c:RegisterEffect(e1)
end
function card.linkcheck(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsStatus(STATUS_SPSUMMON_TURN) and
		c:IsLinkMonster()
end
function card.descon(e, tp, eg, ep, ev, re, r, rp)
	local a = Duel.GetAttacker()
	local bc = a:GetBattleTarget()
	if not bc then
		return false
	end
	return card.linkcheck(a) or card.linkcheck(bc)
end
function card.destg(e, tp, eg, ep, ev, re, r, rp, chk)
	local a = Duel.GetAttacker()
	local bc = a:GetBattleTarget()
	if not a or not bc then
		return false
	end
	local dg = Group.CreateGroup()
	local tg = Group.CreateGroup()
	if card.linkcheck(a) then
		tg=tg+a
		dg=dg+bc
	end
	if card.linkcheck(bc) then
		tg=tg+a
		dg=dg+a
	end
	dg = dg:Filter(Card.IsOnField,nil)
	if chk == 0 then
		return #dg > 0
	end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, LOCATION_MZONE)
end
function card.desop(e, tp, eg, ep, ev, re, r, rp)
	local a = Duel.GetAttacker()
	local bc = a:GetBattleTarget()
	if not a or not bc then
		return false
	end
	local dg = Group.CreateGroup()
	if card.linkcheck(a) and a:IsRelateToEffect(e) then
		dg=dg+bc
	end
	if card.linkcheck(bc) and bc:IsRelateToEffect(e) then
		dg=dg+a
	end
	Duel.Destroy(dg, REASON_EFFECT)
end