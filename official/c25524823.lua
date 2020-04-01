--墓守の審神者
--Gravekeeper's Oracle
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	--summon with 1 tribute
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(s.otcon)
	e2:SetTarget(s.ottg)
	e2:SetOperation(s.otop)
	e2:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e2)
	--summon success
	local e3=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,6))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--tribute check
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
	e4:SetLabelObject(e3)
end
s.listed_series={0x2e}
function s.otfilter(c,tp)
	return c:IsSetCard(0x2e) and (c:IsControler(tp) or c:IsFaceup())
end
function s.otcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
	return c:GetLevel()>6 and minc<=1 and Duel.CheckTribute(c,1,1,mg,tp,zone)
end
function s.ottg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
	local sg=Duel.SelectTribute(tp,c,1,1,mg,tp,zone,true)
	if sg and #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
	sg:DeleteGroup()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsSetCard,nil,0x2e)
	local lv=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		lv=lv+tc:GetLevel()
	end
	e:SetLabel(lv)
	e:GetLabelObject():SetLabel(ct)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.filter(c)
	return c:IsFacedown()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	local b1=e:GetLabelObject():GetLabel()>0
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
	local b3=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2 or b3) end
	local sel=0
	local off=0
	repeat
		local ops={}
		local opval={}
		off=1
		if b1 then
			ops[off]=aux.Stringid(id,2)
			opval[off-1]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(id,3)
			opval[off-1]=2
			off=off+1
		end
		if b3 then
			ops[off]=aux.Stringid(id,4)
			opval[off-1]=3
			off=off+1
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			sel=sel+1
			b1=false
		elseif opval[op]==2 then
			sel=sel+2
			b2=false
		else
			sel=sel+4
			b3=false
		end
		ct=ct-1
	until ct==0 or off<3 or not Duel.SelectYesNo(tp,aux.Stringid(id,5))
	e:SetLabel(sel)
	if (sel&2)~=0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if (sel&1)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local lv=e:GetLabelObject():GetLabel()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
	if (sel&2)~=0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
	end
	if (sel&4)~=0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-2000)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
