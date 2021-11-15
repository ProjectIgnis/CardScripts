--天翔流那キメテラス
-- Kimeterasu the Rising Luna
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160007017,160007001)
	
	--add 1 0 atk monster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--destroy 2 defense
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

--add 1 monster to hand
function s.thfilter(c)
	return  c:GetAttack()==0 and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--destroy up to 2 def
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return #dg>0 end
end
function s.desfilter(c)
	return c:IsPosition(POS_DEFENSE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	--effect
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,2,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end