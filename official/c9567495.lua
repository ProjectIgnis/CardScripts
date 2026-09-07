--ゲート・オブ・ドラゴン
--Dragon Gate
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 6 monsters OR 1 Rank 3 or lower Xyz Monster you control
	Xyz.AddProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--Cannot be used as material for an Xyz Summon the turn it was Xyz Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(s.cannotxyzmatcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Make this card able to attack all monsters your opponent controls, once each, also detach any number of materials from this card, and if you do, it gains 1000 ATK for each card type (Monster, Spell, or Trap) detached, and if it does, any monsters your opponent currently controls lose that much ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.ovfilter(c,tp,lc)
	return c:IsRankBelow(3) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.cannotxyzmatcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsXyzSummoned()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--For the rest of this turn, this card can attack all monsters your opponent controls, once each
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	if c:RemoveOverlayCard(tp,1,c:GetOverlayCount(),REASON_EFFECT)>0 and c:IsFaceup() then
		local atk=1000*Duel.GetOperatedGroup():GetClassCount(Card.GetMainCardType)
		--It gains 1000 ATK for each card type (Monster, Spell, or Trap) detached
		if c:UpdateAttack(atk,RESETS_STANDARD_DISABLE_PHASE_END)==atk then
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
			for tc in g:Iter() do
				--And if it does, any monsters your opponent currently controls lose that much ATK
				tc:UpdateAttack(-atk,RESETS_STANDARD_PHASE_END,c)
			end
		end
	end
end