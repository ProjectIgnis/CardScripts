--ヤジロベーダー
--Yajiro Invader
--Some parts remade by Edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Destroy itself
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Move itself to another monster zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.seqmovcon)
	e3:SetOperation(aux.seqmovop)
	c:RegisterEffect(e3)
	--Destroy cards after moved
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.mvcon)
	e4:SetTarget(s.mvtg)
	e4:SetOperation(s.mvop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
function s.descon(e)
	return e:GetHandler():GetSequence()~=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.mvcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and eg:GetFirst():IsControler(1-tp)
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	tc:CreateEffectRelation(e)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp)
		or not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	local seq1=c:GetSequence()
	local seq2=tc:GetSequence()
	if seq1>4 then return end
	if seq2<5 then seq2=4-seq2
	elseif seq2==5 then seq2=3
	elseif seq2==6 then seq2=1 end
	local nseq=seq1+(seq2>seq1 and 1 or -1)
	if seq1~=seq2 and (Duel.CheckLocation(tp,LOCATION_MZONE,nseq)) then
		Duel.MoveSequence(c,nseq)
		local cg=c:GetColumnGroup()
		if #cg>0 then
			Duel.BreakEffect()
			Duel.Destroy(cg,REASON_EFFECT)
		end
	end
end
