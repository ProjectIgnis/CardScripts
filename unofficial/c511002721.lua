--Earthbound Disciple Geo Glasya-Labolas
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter1,s.fusfilter2)
	--atkdown
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.material_setcode={0x151a,0x351a}
s.miracle_synchro_fusion=true
function s.fusfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x351a) and c:IsType(TYPE_FUSION,fc,sumtype,tp)
end
function s.fusfilter2(c,fc,sumtype,tp)
	return c:IsSetCard(0x351a) and c:IsType(TYPE_SYNCHRO,fc,sumtype,tp)
end
function s.cfilter(tc)
	return tc and tc:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and (bc:IsType(TYPE_FUSION) or bc:IsType(TYPE_SYNCHRO)) and bc:IsFaceup()
		and (s.cfilter(Duel.GetFieldCard(tp,LOCATION_SZONE,5)) or s.cfilter(Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		bc:RegisterEffect(e1)
	end
end
