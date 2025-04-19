--天装騎兵エクエス・フランマ
--Armatos Legio Eques Flamma
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon
	Link.AddProcedure(c,s.matfilter,1,1)
	--cannot be attack target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	 --save co-linked group
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.colinkop)
	c:RegisterEffect(e2)
	--effect damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.dmgcon)
	e3:SetTarget(s.dmgtg)
	e3:SetOperation(s.dmgop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={0x578}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x578,lc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x578) and c:IsMonster()
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.colinkop(e,tp,eg,ep,ev,re,r,rp)
	local clg=e:GetHandler():GetMutualLinkedGroup()
	e:SetLabelObject(clg)
	if #clg>0 then
		clg:KeepAlive()
	else
		clg:DeleteGroup()
	end
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	return e:GetHandler():IsReason(REASON_EFFECT) and g and #g>0
end
function s.dmgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsLinkMonster() and c:GetBaseAttack()>0
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():GetLabelObject()
	if chkc then return g and g:IsContains(chkc) and s.dmgfilter(chkc,e) end
	if chk==0 then return g and g:IsExists(s.dmgfilter,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local dg=g:FilterSelect(tp,s.dmgfilter,1,1,nil,e)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dg:GetFirst():GetBaseAttack())
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		Duel.Damage(tp,atk,REASON_EFFECT,true)
		Duel.Damage(1-tp,atk,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end