--異次元の落とし穴
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_MSET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHANGE_POS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetTarget(s.target2)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:GetReasonPlayer()==tp and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
function s.filter2(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
function s.filter3(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsSummonPlayer(tp) and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local sg=eg:Filter(s.filter,nil,e,1-tp)
		return #sg==1 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,sg:GetFirst(),e)
	end
	local sg1=eg:Filter(s.filter,nil,e,1-tp)
	e:SetLabelObject(sg1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,sg1:GetFirst(),e)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,#sg1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,#sg1,0,0)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local sg=eg:Filter(s.filter3,nil,e,1-tp)
		return #sg==1 and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,sg:GetFirst(),e)
	end
	local sg1=eg:Filter(s.filter3,nil,e,1-tp)
	e:SetLabelObject(sg1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,sg1:GetFirst(),e)
	sg1:Merge(sg2)
	Duel.SetTargetCard(sg1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,#sg1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,#sg1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local sc=e:GetLabelObject()
	if tc1 and tc1:IsRelateToEffect(e) and tc2 and tc2:IsRelateToEffect(e) and sc:IsFacedown() then
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
