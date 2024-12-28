--ロイヤルデモンズ・ヘヴィメタル
--Royal Rebel's Heavy Metal

local s,id=GetID()
function s.initial_effect(c)
	--Check if it tributed a level 5+ monster for its tribute summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Gain ATK equal to 1 of opponent's monster and destroy it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.descond)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:IsExists(Card.IsLevelAbove,1,nil,5) then flag=1 end
	e:SetLabel(flag)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) and e:GetLabelObject():GetLabel()~=0
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		local sg=g:GetMinGroup(Card.GetLevel)
		if #sg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			sg=sg:Select(tp,1,1,nil)
		end
		local dg=sg:AddMaximumCheck()
		if #sg>0 then
			Duel.HintSelection(dg)
			local tc=sg:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end