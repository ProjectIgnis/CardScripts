--ロードブリティッシュ
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	if chk==0 then return true end
	local c=e:GetHandler()
	local t1=c:CanChainAttack()
	local t2=Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local t3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	local op=0
	if t1 or t2 or t3 then
		local m={}
		local n={}
		local ct=1
		if t1 then m[ct]=aux.Stringid(id,1) n[ct]=1 ct=ct+1 end
		if t2 then m[ct]=aux.Stringid(id,2) n[ct]=2 ct=ct+1 end
		if t3 then m[ct]=aux.Stringid(id,3) n[ct]=3 ct=ct+1 end
		local sp=Duel.SelectOption(tp,table.unpack(m))
		op=n[sp+1]
	end
	e:SetLabel(op)
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetCategory(CATEGORY_DESTROY)
	elseif op==3 then
		e:SetProperty(0)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	else
		e:SetProperty(0)
		e:SetCategory(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==2 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif e:GetLabel()==3 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1200,1200,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==1 then
		if c:IsRelateToBattle() then
			Duel.ChainAttack()
		end
	end
end
