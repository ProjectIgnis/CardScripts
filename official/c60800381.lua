--ジャンク・ウォリアー
--Junk Warrior
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Junk Synchron" + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	--Make this card gain ATK equal to the total ATK of all Level 2 or lower monsters you currently control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.material={CARD_JUNK_SYNCHRON}
s.listed_names={CARD_JUNK_SYNCHRON}
s.material_setcode=SET_SYNCHRON
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,CARD_JUNK_SYNCHRON) or c:IsHasEffect(20932152)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local atk=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,2),tp,LOCATION_MZONE,0,nil):GetSum(Card.GetAttack)
	if atk>0 then
		--It gains ATK equal to the total ATK of all Level 2 or lower monsters you currently control
		c:UpdateAttack(atk)
	end
end