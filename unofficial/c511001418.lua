--森のオオカミ
--Forest Wolf
local s,id=GetID()
function s.initial_effect(c)
	--When this card destroys a monster by battle, equip that monster to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,function(ec,_,tp) return ec:GetOriginalType()&TYPE_MONSTER>0 end,Card.EquipByEffectAndLimitRegister,e1)
	--aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),Card.EquipByEffectAndLimitRegister,e1)
	--Check for equip cards equipped to this monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.eqcheck)
	c:RegisterEffect(e2)
	--Special Summon equipped monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	if bc then
		Duel.SetTargetCard(bc)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,bc,1,0,0)
		if bc:IsLocation(LOCATION_GRAVE) then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,0,0)
		end
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc or c:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) and bc and bc:IsRelateToEffect(e) and bc:IsLocation(LOCATION_SZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED) then
		c:EquipByEffectAndLimitRegister(e,tp,bc)
	end
end
function s.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:GetPreviousLocation()==LOCATION_MZONE
end
function s.spfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	if chk==0 then return true end
	if g and #g>0 then
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then return end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or #tg<=0 then return end
	local g=tg:Filter(s.spfilter,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if #g>ft then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,ft,nil)
	for tc in sg:Iter() do
		Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
