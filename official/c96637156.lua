--席取－六双丸
--Musical Sumo Dice Games
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 6 monsters
	Xyz.AddProcedure(c,nil,6,2)
	--Roll die and move to corresponding zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_CONTROL+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.cannot_move(c)
	Duel.SendtoGrave(c,REASON_EFFECT)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsInMainMZone()) then return end
	local dice=Duel.TossDice(tp,1)
	if dice<1 or dice>6 then return end
	local seq=c:GetSequence()
	local col3=Duel.IsDuelType(DUEL_3_COLUMNS_FIELD)
	local max=col3 and 4 or 5
	for i=1,dice do
		seq=seq-1
		if seq==0 and col3 then seq=-2
		elseif seq<-max then seq=max-1 end
	end
	local switch=seq<0
	if switch and not c:IsAbleToChangeControler() then return s.cannot_move(c) end
	local fp=switch and 1-tp or tp
	local nseq=switch and 5+seq or seq
	local tc=Duel.GetFieldCard(fp,LOCATION_MZONE,nseq)
	if Duel.GetMZoneCount(fp,tc,tp,nil,1<<nseq)<1 then return s.cannot_move(c) end
	local win=false
	if tc then
		if c==tc or tc:IsImmuneToEffect(e) or tc:IsType(TYPE_TOKEN) or not c:IsType(TYPE_XYZ) then return s.cannot_move(c) end
		local prev=c:GetOverlayCount()
		Duel.Overlay(c,tc)
		win=(prev<7 and c:GetOverlayCount()>6)
	end
	if switch and Duel.GetControl(c,1-tp,0,0,1<<nseq) or Duel.MoveSequence(c,seq) then
		if win then Duel.Win(tp,WIN_REASON_MUSICAL_SUMO) end
	else return s.cannot_move(c) end
end