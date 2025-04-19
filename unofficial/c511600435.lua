--溶岩魔神ラヴァ・ゴーレム (Anime)
--Lava Golem (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Requires 2 Tributes from your opponent's side of the field to Normal Summon to their field (cannot be Normal Set)
	aux.AddNormalSetProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(s.ttcon)
	e1:SetTarget(s.tttg)
	e1:SetOperation(s.ttop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	--Take 700 damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.ttcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if minc>2 then return false end
	if exeff then
		local ret=exeff:GetValue()
		if type(ret)=="function" then
			ret={ret(exeff,c)}
			if #ret>1 then
				zone=(ret[2]>>16)&0x7f
			end
		end
	end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(aux.IsZone,tp,0,LOCATION_MZONE,nil,relzone,tp)
	return Duel.CheckTribute(c,2,2,mg,1-tp,zone)
end
function s.tttg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	if exeff then
		local ret=exeff:GetValue()
		if type(ret)=="function" then
			ret={ret(exeff,c)}
			if #ret>1 then
				zone=(ret[2]>>16)&0x7f
			end
		end
	end
	local mg=Duel.GetMatchingGroup(aux.IsZone,tp,0,LOCATION_MZONE,nil,relzone,tp)
	local g=Duel.SelectTribute(tp,c,2,2,mg,1-tp,zone,true)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(700)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,700)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end