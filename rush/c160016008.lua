--トランザム・プライム・アーマーノヴァ
--Transamu Praime Armor Nova
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:RegisterFlagEffect(FLAG_TRIPLE_TRIBUTE,0,0,1)
	--Summon with 1 Tribute treated as 3
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,2),s.otfilter)
	--Summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,3,3,SUMMON_TYPE_TRIBUTE+1,aux.Stringid(id,0))
	--summon/set with 1 tribute
	local e2=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,1),nil,s.otop)
	--tribute check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	--Gain ATK when it is Tribute Summoned
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_COST)
	e4:SetOperation(s.facechk)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.otfilter(c)
	return c:HasFlagEffect(160015135) and c:IsFaceup()
end
function s.otop(g,e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	--change base attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1800)
	c:RegisterEffect(e1)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	for tc in g:Iter() do
		local lvl=tc:GetOriginalLevel()
		if #g==1 then
			atk=atk+lvl*100*3
		elseif #g==2 and tc:HasFlagEffect(FLAG_HAS_DOUBLE_TRIBUTE) then
			atk=atk+lvl*100*2
		else
			atk=atk+lvl*100
		end
	end
	if e:GetLabel()==1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetCondition(s.condition)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
		c:RegisterEffect(e1)
	end
end
function s.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_TRIBUTE+1
end