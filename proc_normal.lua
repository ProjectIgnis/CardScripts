--tribute
function Auxiliary.AddNormalSummonProcedure(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SUMMON_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSummonCondition2())
	end
	e1:SetValue(val)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.NormalSummonCondition1(min,max,f)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		return minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
	end
end
function Auxiliary.NormalSummonCondition2()
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		return false
	end
end
function Auxiliary.NormalSummonTarget(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		local g=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.GetCurrentChain()==0)
		if g and #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function Auxiliary.NormalSummonOperation(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end
--add normal set
function Auxiliary.AddNormalSetProcedure(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SET_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SET_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSetCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSetTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSetOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSetCondition2())
	end
	e1:SetValue(val)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.NormalSetCondition1(min,max,f)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		return minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
	end
end
function Auxiliary.NormalSetCondition2()
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		return false
	end
end
function Auxiliary.NormalSetTarget(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		local mg=Duel.GetTributeGroup(c)
		mg=mg:Filter(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg=mg:Filter(f,nil,tp)
		end
		local g=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.GetCurrentChain()==0)
		if g and #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function Auxiliary.NormalSetOperation(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end
